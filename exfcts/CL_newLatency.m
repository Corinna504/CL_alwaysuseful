function res = CL_newLatency(res)
%modified latency for variance between 0:20ms to stimuli onset
% 
%@CL 22.01.2016
% %

if ~isempty(res.sdfs.extras)
    res.vars2 = var([horzcat(res.sdfs.s{:}), res.sdfs.extras{1}.sdf], 0, 2);
else
    res.vars2 = var(horzcat(res.sdfs.s{:}), 0, 2);
end


sd      = sqrt(res.vars2);
noise   = mean(sd(200:400)); 


if max(sd)>mean(noise)*5
    
    sd2 = sd-noise;     % normalizer for baseline variability
    
    % first time of half max of response
    idx = find( sd2 >= (max(sd2)/2), 1, 'first');  
    res.latencyToHalfMax = res.times(idx);
    
    idx = find( sd2 >= (max(sd2)/2), 1, 'last');  
    res.dur = (res.times(idx) - res.latencyToHalfMax)/10;
    
    res.latFP = friedmanpriebe(round(sd(200:end).*100))/10;
    
end

