function [ res, mn_rate, fitparam ] = RCsubspace( ex, varargin )
%RCsupspace 
% This is a batch function calling 
% HN_computeLatencyAndNetSpk and
% fitgauss


j=1; p_flag = false;
while j<= length(varargin)
   switch varargin{j}
       case 'plot'
           p_flag = varargin{j+1};
   end
   j=j+2;
end


ex.Trials = ex.Trials([ex.Trials.Reward]>0);


% get errorbars by resampling
nsmpl = 10;       % number of resampling processes  
[res, mn_rate] = resampleRC(ex, nsmpl);


if ~isfield(res, 'latencyToHalfMax')
    res.dur = 0;
    res.lat = -1;
else
    res.lat = res.latencyToHalfMax /10;
end


%%% fit gauss shape
offset = abs(min([mn_rate.mn]));

% CL fit
i2= sum([mn_rate.or]<360);
[~, ~, val] = fitgauss( [mn_rate(1:i2).mn]+offset, [mn_rate(1:i2).sd], [mn_rate(1:i2).or] );

% HN fit
[fitHN,~,~,~,~,~]  = FitGauss_HN(val.uqang, val.mn, 'lin' );

% CL fit with HN parameters
[fitHN.mean, val.uqang] = unwrapdeg(fitHN.mean, val.uqang);

[fitparam, gaussr2, val] =...
    fitgauss( [mn_rate(1:i2).mn]+offset, [mn_rate(1:i2).sd], [mn_rate(1:i2).or], fitHN, val );

fitparam.b = fitparam.b - offset;
fitHN.base = fitHN.base - offset;

val.mn = val.mn - offset;
fitparam.val = val;
fitparam.r2 = gaussr2;
fitparam.HN = fitHN;


% plot results if necessary
if p_flag
    figure;
    x = 1:length(mn_rate);
    
    errorbar(x, [mn_rate.mn], [mn_rate.sd]); hold on;
    
    n = res.sdfs.n;
    if ~isempty(res.sdfs.extras);   
        errorbar(x(end), mn_rate(end).mn, mn_rate(end).sd, 'g');
        n = [n; res.sdfs.extras{1}.n];    
    end
    text(x, [mn_rate.mn], num2str(n));    
end
    


end




function [res, mn_rate] = resampleRC(ex, nsmpl)
% randomly choose n trials and compute netspikes
% do this nsmpl times


ex_boot = ex;
res = HN_computeLatencyAndNetSpk([], ex); 

res_boot = cell(nsmpl,1); % results from bootstrapping samples

for i = 1:nsmpl
    
    % get indices from uniform distribution between 1 and number of Trials
    bootidx = randi(length(ex.Trials), length(ex.Trials), 1); 
    
    % assign Trials
    ex_boot.Trials = ex.Trials(bootidx);
    
    % use HN function to compute the usual res struct
    res_boot{i} = HN_computeLatencyAndNetSpk([], ex_boot);
    nspk(:,i) = res_boot{i}.netSpikesPerFrame;
    
    
    if ~isempty(res.netSpikesPerFrameBlank)
        nspk_blank(i) = res_boot{i}.netSpikesPerFrameBlank(1);
    end

end



% get the distribution information
mn_rate = struct();
% for orientation data
for i2=1:length(res.or)
    mn_rate(i2).mn = mean(nspk(i2, :));
    mn_rate(i2).sd = std(nspk(i2, :));
    mn_rate(i2).var = var(nspk(i2, :));
    mn_rate(i2).or = res.or(i2);
end

%for blanks
if ~isempty(res.netSpikesPerFrameBlank)
    mn_rate(i2+1).mn = mean(nspk_blank);
    mn_rate(i2+1).sd = std(nspk_blank);
    mn_rate(i2+1).var = var(nspk_blank);
    mn_rate(i2+1).or = 100000;
end


end