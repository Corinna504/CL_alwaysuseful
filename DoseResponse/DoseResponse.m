function dat = DoseResponse()


clear dat
fileID = fopen('filenames.txt', 'r');
fnames = textscan(fileID, '%s'); fnames = fnames{1};

dat = struct('unit', []);

figure;

for i = 1:length(fnames)

    
    fdir = [fnames{i}(1:18) '\'];
    dat(i).fname = fnames{i}(19:end);
    dat(i).unit = str2double(fdir(15:18));
    
    dat(i).is5HT= ~isempty(strfind(dat(i).fname, '5HT'));
    dat(i).isc1 = ~isempty(strfind(dat(i).fname, 'c1'));
    
    
    % add the experiment number in the order of recording
    if length(dat)==1
        dat(i).numinexp = 1;
    else
        if dat(i).unit==dat(i-1).unit && dat(i).isc1 == dat(i-1).isc1
            dat(i).numinexp = dat(i-1).numinexp+1;
        else
%             plotDat(dat, i)
            dat(i).numinexp = 1;
        end
    end
            

    % and get mean firing rate
    [mnspk, dat(i).dose, dat(i).timeofrec] = PlotTC( fdir, dat(i).fname, 'plot', false );
%     if abs(dat(i).dose-5)<=2
%         dat(i).dose=5;
%     elseif abs(dat(i).dose-15)<=2
%         dat(i).dose=15;
%     elseif abs(dat(i).dose-20)<=2
%         dat(i).dose=20;
%     elseif abs(dat(i).dose-25)<=2
%         dat(i).dose=25;
%     end
    
    dat(i).frate = mnspk;
    
    % get the firing relative to the baseline response
    ind = find([dat.unit]==dat(i).unit & [dat.numinexp]==1 & [dat.isc1] == dat(i).isc1, 1, 'first');
    
    % only gain
    [dat(i).linfrate, dat(i).relfrate] = ...
        fit_bothsubj2error(dat(ind).frate, dat(i).frate);
    dat(i).relfrate = log(dat(i).relfrate);
    
    % alternatively modulation index
    dat(i).moduidx = (sum(dat(i).frate) - sum(dat(ind).frate)) / ....
        (sum(dat(i).frate) + sum(dat(ind).frate));
end



if dat(1).relfrate == 1
    set(gca, 'YScale', 'log');
end
crossl

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