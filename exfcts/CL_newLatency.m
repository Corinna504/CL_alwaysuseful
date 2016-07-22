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
    
    [res.lat(i), res.dur(i), res.latFP(i)] = ...
        CL_newLatency_helper(res.vars2(:,i), res.times);
end

end




function [lat, dur, latfp] = CL_newLatency_helper(vars, times)


lat     = -1;
dur     = -1;
latfp   = -1;
sd      = sqrt(vars);
noise   = mean(sd(200:400)); 


if max(sd)>mean(noise)*5
    
    sd2 = sd-noise;     % normalizer for baseline variability
    
    % first time of half max of response
    idx = find( sd2 >= (max(sd2)/2), 1, 'first');  
    lat = times(idx)/10;
    
    idx = find( sd2 >= (max(sd2)/2), 1, 'last');  
    dur = times(idx)/10 - lat;
    
    latfp = friedmanpriebe(round(sd(200:end).*100))/10;
    
end

end

