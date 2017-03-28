function [ res, mn_rate, fitparam ] = RCsubspace( ex, varargin )
%RCsupspace 
% This is a batch function calling 
% HN_computeLatencyAndNetSpk and
% fitgauss


j=1; p_flag = false;    lat_flag = true;
nsmpl = 1000;       % number of resampling processes  

while j<= length(varargin)
   switch varargin{j}
       case 'plot'
           p_flag = varargin{j+1};
       case 'lat_flag'
           lat_flag = varargin{j+1};
       case 'bootstrap_n'
           nsmpl = varargin{j+1};
   end
   j=j+2;
end
if p_flag; figure; end;

ex.Trials = ex.Trials([ex.Trials.Reward]>0);

% get errorbars by resampling
[res, mn_rate, bootsmpl] = resampleRC(ex, nsmpl, 'lat_flag', lat_flag);

% fit tuning curves
fitparam = fitOR2(mn_rate);

mn_rate.bootstrap = bootsmpl;
if size(res.sdfs.mn_rate(1).mn,1)>1 && size(res.sdfs.mn_rate(1).mn,2)>1
    
    % I am not sure here how to fit in 2D therefore I fit each orientation
    % TC at each contrast and one contrast TC collapsed over all orientations
    for i = 1:size(res.sdfs.mn_rate(1).mn,2)
        temp.mn     = res.sdfs.mn_rate(1).mn(:,i);
        temp.sem    = res.sdfs.mn_rate(1).sem(:,i);
        temp.or     = res.sdfs.x(:,1);
        fitparam.others.OR(i) = fitOR2(temp);
    end
    
    corate = mean(res.sdfs.mn_rate(1).mn, 1);
    copar = res.sdfs.y(1,:);
    if length(res.sdfs.mn_rate)>1
        corate = [corate, res.sdfs.mn_rate(2).mn];
        copar = [copar, 3];
    end
    fitparam.others.CO = fitCO( corate, copar);
end



% plot results if necessary
if p_flag
    subplot(2,2,1);
    plot(fitparam.x, fitparam.y, 'r-'); hold on;
    errorbar(fitparam.val.or, fitparam.val.mn, fitparam.val.sem, 'rx');
    
    subplot(2,2,[3 4]);
    c = hsv(length(res.sdfs.s));
    % stimulus triggered SDFs
    for i = 1:length(res.sdfs.s) % orientation
        plot(res.times/10, res.sdfs.s{i}, 'Color', c(i,:)); ho
        leg{i} = sprintf('%1.0f \t n=%1.0f', res.sdfs.x(i), res.sdfs.n(i));
    end
    plot(res.times/10, res.sdfs.extras{1}.sdf, 'r:'); ho
    legend(leg, 'Location', 'EastOutside');
    
    s = horzcat(res.sdfs.s{:});
    meanfr = mean(mean(s(201:400),2));
    
    latfp = res.latFP; 
    lathmax = res.lat; 
    dur = res.dur; 
    
    ylim_ = get(gca, 'ylim'); 
    
    plot([latfp latfp], ylim_, 'k');
    plot([lathmax lathmax], ylim_, 'k--');
    plot([lathmax+dur, lathmax+dur], ylim_, 'k');

    
    title(sprintf('lat: %1.1f (hmax %1.1f), dur: %1.1f, \n average sd: %1.2f, mean fr: %1.2f',...
        res.latFP, res.lat, res.dur, mean(sqrt(res.vars(201:400))), meanfr));
    xlim([0 160]); grid on;
    ylabel('spk/s');

end

end



 %%
function fitparam = fitOR2(val)

mn = val.mn(val.or<180)';
sem = val.sem(val.or<180)';
or = val.or(val.or<180)';

% fit gaussian function to the mean values
fitparam = fitOR( mn, sem, or);

end


%%
function [res, mn_rate, bootsmpl] = resampleRC(ex, nsmpl, varargin)
% randomly choose n trials and compute netspikes
% do this nsmpl times


rng(9123234);

res = HN_computeLatencyAndNetSpk([], ex, varargin{:});

res_boot = cell(nsmpl,1); % results from bootstrapping samples


parfor i = 1:nsmpl
    
    % get indices from uniform distribution between 1 and number of Trials
    bootidx = randi(length(ex.Trials), length(ex.Trials), 1); 
    
    % assign Trials
    ex_boot = ex;
    ex_boot.Trials = ex.Trials(bootidx);
    
    % use HN function to compute the usual res struct
    res_boot{i} = HN_computeLatencyAndNetSpk([], ex_boot, 'lat_flag', 0);
%     latfp_boot(i) = res_boot{i}.latFP;
%     lathmax_boot(i) = res_boot{i}.lat;
    bootsmpl(:,:,i) = res_boot{i}.netSpikesPerFrame;
    
    
    if ~isempty(res.netSpikesPerFrameBlank)
        nspk_blank(i) = res_boot{i}.netSpikesPerFrameBlank(1);
    else
            
    end

end


% get the distribution information
mn_rate = struct();
% for orientation data
for i1=1:size(bootsmpl,1) % contrast
    for i2=1:size(bootsmpl,2) % orientation
        res.sdfs.mn_rate(1).mn(i1,i2) = mean(bootsmpl(i1, i2, :));
        res.sdfs.mn_rate(1).sem(i1,i2) = std(bootsmpl(i1, i2, :));
    end
end
mn_rate.or= res.sdfs.x(:,1); 
[~, maxi]= max(res.sdfs.y(1,:));

mn_rate.mn  = res.netSpikesPerFrame(:, maxi);
mn_rate.sem = std( bootsmpl, 0, 3  );


%for blanks
if ~isempty(res.netSpikesPerFrameBlank)
    res.sdfs.mn_rate(2).mn = mean(nspk_blank);
    res.sdfs.mn_rate(2).sem = std(nspk_blank);
    
    mn_rate.or= [mn_rate.or; 1000];
    mn_rate.mn = [mn_rate.mn; res.sdfs.mn_rate(2).mn];
    mn_rate.sem = [mn_rate.sem; res.sdfs.mn_rate(2).sem];
end


% res.sdfs.lat_boot = latfp_boot;
% res.sdfs.lathmax_boot = lathmax_boot;
end