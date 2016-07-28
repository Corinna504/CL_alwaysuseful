function dat = DoseResponse(filename)


clear dat 
fileID = fopen(filename, 'r');
fnames = textscan(fileID, '%s'); fnames = fnames{1};
fnames = strrep(fnames, 'J', 'D');

fdir = 'D:\data';

if isempty(strfind(fnames{1}, 'mango'))
    uidx = 14:17;
else 
    uidx = 15:18;
end
dat = struct('unit', []);

i =1;
for k = 1:length(fnames)
    
    fdir = [fnames{k}(1:uidx(end)), '\'];
    fprintf('processing k=%1.0f \n', k);
    if isempty(strfind(fnames{k}, 'CO')) || ~isempty(strfind(fnames{k}, 'RC'))
        continue
    end
    
    dat(i).fdir = fdir;
    dat(i).fname = fnames{k}(19:end);
    dat(i).unit = str2double(fdir(uidx));
    dat(i).is5HT= ~isempty(strfind(dat(i).fname, '5HT'));
    dat(i).isNaCl= ~isempty(strfind(dat(i).fname, 'NaCl'));
    dat(i).isc1 = ~isempty(strfind(dat(i).fname, 'c1'));
    dat(i).isRC = ~isempty(strfind(fnames{k}, 'RC'));
    
    % and get mean firing rate
    [mnspk, dat(i).dose, dat(i).timeofrec, dat(i).stim, dat(i).vals] = ...
        PlotTC( fdir, dat(i).fname, 'plot', false );
    [~, mnspk_i] = max(max(mnspk,[],2));
    mnspk = mnspk(mnspk_i, :);
    
    if strcmp(dat(i).stim, 'co') 
        dat(i).fitparam = fitCO(mnspk, dat(i).vals);
        dat(i).auc = dat(i).fitparam.auc;
    else
        dat(i).fitparam = [];
        dat(i).auc = 0;
    end
    
    
    % add the experiment number in the order of recording
    if length(dat)==1
        dat(i).numinexp = 1;
    else
        if dat(i).unit==dat(i-1).unit && dat(i).isc1 == dat(i-1).isc1 ...
                && strcmp(dat(i).stim, dat(i-1).stim)
            dat(i).numinexp = dat(i-1).numinexp+1;
        else
%             plotDat(dat, i)
            dat(i).numinexp = 1;
        end
    end
            

    if dat(i).dose >= 1
        if dat(i).dose <= 10
            dat(i).bindose=5;
        elseif dat(i).dose <= 20
            dat(i).bindose=15;
        elseif dat(i).dose <= 30
            dat(i).bindose=25;
        elseif dat(i).dose <= 40
            dat(i).bindose=35;
        else
            dat(i).bindose=45;
        end
    elseif dat(i).dose == 0
        dat(i).bindose=0;
    else
        dat(i).bindose=-1;
    end
        
        
    dat(i).frate = mnspk;
    
    % get the firing relative to the baseline response
    ind = find([dat.unit]==dat(i).unit & [dat.numinexp]==1 & ...
        [dat.isc1] == dat(i).isc1 & strcmp({dat.stim}, dat(i).stim), 1, 'first');
    
    % only gain
    try
        stim1 = ismember(dat(i).vals, dat(ind).vals);
        stim2 = ismember(dat(ind).vals, dat(i).vals);
        
    [dat(i).yoff, dat(i).gslope,...
        dat(i).regr2] =perpendicularfit(dat(ind).frate(stim1), dat(i).frate(stim2), ...
                    var(dat(i).frate(stim2))/var(dat(ind).frate(stim1)));
    catch ME
        warning(ME.message)
    end
    
%     dat(i).relfrate = log(dat(i).relfrate);
    dat(i).relauc = dat(i).auc/dat(ind).auc;
    
    
    % alternatively modulation index
    dat(i).moduidx = (sum(dat(i).frate) - sum(dat(ind).frate)) / ....
        (sum(dat(i).frate) + sum(dat(ind).frate));
    i = i+1;
end


% if dat(1).relfrate == 1
%     set(gca, 'YScale', 'log');
% end
% crossl

for unt = unique([dat.unit])
    for cluster = 1:2
        ind1 = [dat.unit] == unt & [dat.isc1] == (cluster-1);
        
        if sum(ind1)>0
            % add the relative time of recording
            t0 = dat(find(ind1, 1, 'first')).timeofrec;
            
            t_new = [dat(ind1).timeofrec] - t0;
            t_new = num2cell(t_new);
            [dat(ind1).timerel2strt] = deal(t_new{:});
        end
    end
    
end

clearvars -except dat;

%%
% plotDose(dat);
% plotOrder(dat);


end



function plotDat(dat, i)
ind1 = [dat.unit] == dat(i-1).unit & [dat.isc1] == dat(i).isc1 ;
ind2 = [dat.is5HT]==1;

plot([dat(ind1).numinexp], [dat(ind1).relfrate], 'r-'); hold on;

ind = ind1 & ind2;
scatter([dat(ind).numinexp], [dat(ind).relfrate], ...
    10*[dat(ind).dose], ...
    'r', 'MarkerFaceAlpha', 0.5); hold on;

ind = ind1 & ~ind2;
scatter([dat(ind).numinexp], [dat(ind).relfrate], 80, ...
    'r', 'filled', 'MarkerFaceAlpha', 0.5); hold on;
end


function plotDose(dat)
figure('Position', [1161 719    365   265]);
id = find([dat.is5HT]);
for i = id
    scatter(dat(i).dose, dat(i).relfrate, 60, 'r', 'MarkerFaceAlpha', 0.5);
    hold on;
    scatter(dat(i).dose-1, dat(i-1).relfrate, 60, 'r', 'filled', ...
        'MarkerFaceAlpha', 0.5);
end
xlabel('dose'); ylabel('relative firing rate');
if dat(1).relfrate ==1
    set(gca, 'YScale', 'log')
end

crossl;
title('filled: baseline/recovery, empty: 5HT');
set(gca, 'xlim', [0 max([dat.dose])+0.5]);

ploterr( dat, 'dose' )
set(gca, 'xlim', [0 10]);
title('');
end


function plotOrder(dat)

figure('Position', [1161 719    365   265]);
id = find([dat.is5HT]);
for i = id
    scatter(dat(i).numinexp, dat(i).relfrate, 60, 'r', 'MarkerFaceAlpha', 0.5);
    hold on;
    scatter(dat(i).numinexp-0.5, dat(i-1).relfrate,  60, 'r', 'filled', ...
        'MarkerFaceAlpha', 0.5);
end
xlabel('number in the exp'); ylabel('relative firing rate');
if dat(1).relfrate ==1
    set(gca, 'YScale', 'log')
end

crossl;
title('filled: baseline/recovery, empty: 5HT');
set(gca, 'xlim', [1 max([dat.numinexp])]);

ploterr( dat, 'numinexp' )
set(gca, 'xlim', [0 max([dat.numinexp])]);
% ploterr( dat, 'timerel2strt' )
title('');
end