function res = CL_newLatency(res)
%modified latency for variance between 0:20ms to stimuli onset
% 
%@CL 22.01.2016
% %

for i = 1:size(res.sdfs.s, 2)
    if ~isempty(res.sdfs.extras)
        res.vars2(:,i) = var([horzcat(res.sdfs.s{:, i}), res.sdfs.extras{1}.sdf], 0, 2);
    else
        res.vars2(:,i) = var(horzcat(res.sdfs.s{:, i}), 0, 2);
    end
    
    [res.sdfs.lat2hmax(i), res.sdfs.dur(i), res.sdfs.latFP(i)] = ...
        CL_newLatency_helper(res.vars2(:,i), res.times);
end

[~,co_idx]= max(res.sdfs.y(1,:));
res.lat = res.sdfs.lat2hmax(co_idx);
res.dur = res.sdfs.dur(co_idx);
res.latFP = res.sdfs.latFP(co_idx);




end




function [lat2hmax, dur, latfp, pPoisson] = CL_newLatency_helper(vars, times)


lat2hmax     = -1;
dur     = -1;
latfp   = -1;
pPoisson = 0;
sd      = sqrt(vars);
noise   = mean(sd(200:400)); 


if max(sd)>mean(noise)*3.5
    
    sd2 = sd-noise;     % normalizer for baseline variability
    
    % first time of half max of response
    idx = find( sd2 >= (max(sd2)/2), 1, 'first');  
    lat2hmax = times(idx)/10;
    
    idx = find( sd2 >= (max(sd2)/2), 1, 'last');  
    dur = times(idx)/10 - lat2hmax;
    
    [latfp, ~, pPoisson] = friedmanpriebe(round(sd(200:end).*100), ...
        'minTheta', 250, 'responseSign', 0);
    latfp = latfp/10;
end

end

