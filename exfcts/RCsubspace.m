function [ res, mn_rate, fitparam ] = RCsubspace( ex, varargin )
%RCsupspace 
% This is a batch function calling 
% HN_computeLatencyAndNetSpk and
% fitgauss


j=1; p_flag = false;    lat_flag = true;
while j<= length(varargin)
   switch varargin{j}
       case 'plot'
           p_flag = varargin{j+1};
       case 'lat_flag'
           lat_flag = varargin{j+1};
   end
   j=j+2;
end
if p_flag; figure; end;

ex.Trials = ex.Trials([ex.Trials.Reward]>0);

% get errorbars by resampling
nsmpl = 1000;       % number of resampling processes  
[res, mn_rate] = resampleRC(ex, nsmpl, 'lat_flag', lat_flag);

% fit tuning curves
fitparam = fitOR(mn_rate, p_flag, res.sdfs.n);

if size(res.sdfs.mn_rate(1).mn,1)>1 && size(res.sdfs.mn_rate(1).mn,2)>1
    
    % I am not sure here how to fit in 2D therefore I fit each orientation
    % TC at each contrast and one contrast TC collapsed over all orientations
    for i = 1:size(res.sdfs.mn_rate(1).mn,2)
        temp.mn     = res.sdfs.mn_rate(1).mn(:,i);
        temp.sem    = res.sdfs.mn_rate(1).sem(:,i);
        temp.or     = res.sdfs.x(:,1);
        fitparam.others.OR(i) = fitOR(temp, p_flag, res.sdfs.n(:,i));
    end
    
    corate = mean(res.sdfs.mn_rate(1).mn, 1);
    copar = res.sdfs.y(1,:);
    if length(res.sdfs.mn_rate)>1
        corate = [corate, res.sdfs.mn_rate(2).mn];
        copar = [copar, 3];
    end
    fitparam.others.CO = fitCO( corate, copar);
end

end


 %%
function fitparam = fitOR(mn_rate, p_flag, n)

mn = mn_rate.mn(mn_rate.or<180);
sem = mn_rate.sem(mn_rate.or<180);
or = mn_rate.or(mn_rate.or<180);


%%% fit gauss shape
offset = abs(min(mn));

% CL fit
[~, ~, val] = fitgauss( mn+offset, sem, or );

% HN fit
[fitHN,~,~,~,~,~]  = FitGauss_HN(val.uqang, val.mn, 'lin' );

% CL fit with HN parameters
[fitHN.mean, val.uqang] = unwrapdeg(fitHN.mean, val.uqang);
[fitparam, gaussr2, val] = fitgauss( mn+offset, ...
                                    sem, ...
                                    or, fitHN, val );

fitparam.b   = fitparam.b - offset;
fitHN.base      = fitHN.base - offset;

val.mn          = val.mn - offset;
fitparam.val = val;
fitparam.r2  = gaussr2;
fitparam.HN  = fitHN;


% plot results if necessary
if p_flag
%     hold on;
    figure
    x = fitparam.mu-100 : fitparam.mu+100;
    y = gaussian(fitparam.mu, fitparam.sig, fitparam.a, fitparam.b,x);
    plot(x, y, 'r--'); hold on;
    
    errorbar(fitparam.val.uqang, fitparam.val.mn, fitparam.val.sd); hold on;
    
end

end


%%
function [res, mn_rate] = resampleRC(ex, nsmpl, varargin)
% randomly choose n trials and compute netspikes
% do this nsmpl times

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
    nspk(:,:,i) = res_boot{i}.netSpikesPerFrame;
%     latfp_boot(i) = res_boot{i}.latFP;
%     lathmax_boot(i) = res_boot{i}.lat;
    
    if ~isempty(res.netSpikesPerFrameBlank)
        nspk_blank(i) = res_boot{i}.netSpikesPerFrameBlank(1);
    end

end


% get the distribution information
mn_rate = struct();
% for orientation data
for i1=1:size(nspk,1) % contrast
    for i2=1:size(nspk,2) % orientation
        res.sdfs.mn_rate(1).mn(i1,i2) = mean(nspk(i1, i2, :));
        res.sdfs.mn_rate(1).sem(i1,i2) = std(nspk(i1, i2, :));
    end
end
mn_rate.or= res.sdfs.x(:,1); 
[~, maxi]= max(res.sdfs.y(1,:));

mn_rate.mn  = res.netSpikesPerFrame(:, maxi);
mn_rate.sem = std( nspk, 0, 3  );


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