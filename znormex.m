function [ex, spkrate, spkcount] = znormex(ex, exinfo)
%znormex
% converts spike rates to z-normed data for each condition pair
% norm_flag determines if to use spike rate (norm_falg = 1) or spike count
% (norm_flag = 0)


param1 = exinfo.param1;
parvls = unique( [ ex.Trials.(param1) ] );

j = 1;

if exinfo.isadapt
    time = 0:0.001:5;
else
    time = 0.001:0.001:0.45;
end


for par = parvls
    
    % z-scored spikes for this stimulus
    ind = par == [ ex.Trials.(param1) ];
    spkrate(j).nrep = sum(ind);
    spkrate(j).(param1) = par;

    
    % mean spike rates
    spkrate(j).mn  = mean([ex.Trials(ind).spkRate]);
    spkrate(j).var = var([ex.Trials(ind).spkRate]);
    spkrate(j).sd = std([ex.Trials(ind).spkRate]);
    spkrate(j).sem = spkrate(j).sd / sqrt( spkrate(j).nrep );
    
  
    % mean spike count
    spkcount(j).(param1) = par;
    spkcount(j).mn  = mean([ex.Trials(ind).spkCount]);
    spkcount(j).var = var([ex.Trials(ind).spkCount]);
    
       
    % z normed spike counts
    z = zscore( [ ex.Trials(ind).spkCount ] );
    z = num2cell(z);
    [ex.Trials(ind).zspkrate] = deal(z{:});
    
    % raster - contains 0 for times without spike and 1 for times of spikes
    % is reduced for times between -0.5s and 0.5s around stimulus onset
    idxct = find(ind);
    ct = ex.Trials(idxct);    % current trials
    
    ex.trials_n(j) = sum(ind);
    ex.raster{j,1} = zeros(length(ct), length(time));
    ex.rastercum{j,1} = nan(length(ct), length(time));
    
    
    % convert the spike times into a matrix raster with bits
    for k = 1:length(idxct)
        
        t_strt = ct(k).Start - ct(k).TrialStart;
        if exinfo.isadapt
            t_strt = t_strt(t_strt<=5);
        end
        
        idx = round((ct(k).Spikes(...
            ct(k).Spikes>=t_strt(1) & ct(k).Spikes<=t_strt(end))-t_strt(1)) ...
            *1000);
        
        idx(idx==0) = 1; % avoid bad indexing
        
        ex.raster{j}(k, idx) = 1;
        ex.rastercum{j}(k, idx) = k;
        
    end
    
    j = j+1;
    
end


ex.raster_pval = parvls;

end

















