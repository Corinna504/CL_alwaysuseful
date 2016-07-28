function [lat, pval, psth_out, ntrial] = getLatencyDG(exinfo, oTrials, smooth_flag)
% returns latency and unsmoothed, but normalized psth for trials with
% drifting grating


if exinfo.isadapt
    time = 0:0.001:5;
else 
    time = 0.001:0.001:0.45;
end

ntrial = length(oTrials);
raster = zeros(ntrial, length(time));


% loop through all the trials and get the raster
for t = 1:ntrial
        
    ct = oTrials(t);
    t_strt = ct.Start - ct.TrialStart;
    
    if exinfo.isadapt
        t_strt = t_strt(t_strt<=5);
    end
    
    idx = round((ct.Spikes(...
        ct.Spikes>=t_strt(1) & ct.Spikes<=t_strt(end))-t_strt(1)) ...
        *1000);
    
    idx(idx==0) = 1; % avoid bad indexing
    raster(t, idx) = 1;
end

psth = (sum(raster, 1) ./ size(raster, 1)) *100 ;


% psth smoothing
kernel = gaussian(0, 20, 1, 0, 0:70); 
kernel = kernel/sum(kernel);

psth_smooth = conv(psth, kernel);
psth_smooth = psth_smooth(1:end-71);


if ~isempty(oTrials)
    sprintf('id %d par %1.1f', exinfo.id, oTrials(1).(exinfo.param1));
    [lat, ~, pval] = friedmanpriebe(sum(raster, 1)', 'minTheta', 20, ...
        'maxTheta', 150, 'responseSign', 1);
else
    lat = 0;
    pval = 1;
end




% output
psth_out = psth;
if nargin == 3 
    if smooth_flag 
        psth_out = psth_smooth;
    end
end

end