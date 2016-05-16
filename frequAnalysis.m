function [pwst_mn, pwst_sd, pwbs_mn, pwbs_sd] = frequAnalysis( exinfo, lfpfile )
% filters and interpolates lfp traces and returns their power spectra


% set time bin
time = 0:0.001:0.5;

% load ex file with lfp traces and only
ex = loadCluster(lfpfile);
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);

% notch filter variables
Fs = 1000;              % sampling frequency
wo = 50/(Fs/2);         % to be filtered frequency
bw = wo/5;              % 50Hz / quality factor

[b,a] = iirnotch(wo,bw);


% perform functions on each trial lfp
for ind = 1:length(ex.Trials)
    
    if isempty(ex.Trials(ind).LFP) || all(ex.Trials(ind).LFP_ts < 0) || ...
            ~any(ex.Trials(ind).LFP_ts >= 0.48)
        ex.Trials(ind).powstim = nan(257, 1);
        ex.Trials(ind).powbase = nan(257, 1);
        ex.Trials(ind).LFP_interp = [];
    else
        %%% filter 50Hz
        ex.Trials(ind).LFP_filt = filter(b, a, ex.Trials(ind).LFP);
        ex.Trials(ind).LFP_interp = ...
            interp1(ex.Trials(ind).LFP_ts, ex.Trials(ind).LFP_filt, time);
        
        %%%  get power spectrum
        %Sampled data in mV for pre stimulus and inter stimulus time
        interstim   = ex.Trials(ind).LFP_interp(1:end);
        prestim     = ex.Trials(ind).LFP_interp(1:end);
        
        % mutli taper approach
        % power spectrum density returned by pmtm is normalized per unit frequency
        % in Chalk et al. time halfbandwidth was 3 and k was 5
        nw      = 3;         % time half bandwidth product
        nfft    = 2^nextpow2(length(interstim));
        
        ex.Trials(ind).powstim = pmtm(interstim, nw, nfft, Fs);
        ex.Trials(ind).powbase = pmtm(prestim, nw, nfft, Fs);
        
        
    end
    
end  
exfull = ex; 
ex.Trials = ex.Trials( ~cellfun(@isempty, {ex.Trials.LFP_interp}));
% save(strrep(lfpfile, '.mat', [num2str(exinfo.ocul) '.mat']), 'ex');


%%
% average pre stimulus power spectrum across all trials
pwbs_mn = nanmean(horzcat(exfull.Trials.powbase), 2);
pwbs_sd = nanstd(horzcat(exfull.Trials.powbase), 0, 2);

% average inter stimulus power spectrum between stimuli conditions
parvls = unique( [ exfull.Trials.(exinfo.param1) ] );
j = 1;
for par = parvls
    ind = par == [ exfull.Trials.(exinfo.param1) ];
    pwst_mn(j, :) = nanmean(horzcat(exfull.Trials(ind).powstim), 2);
    pwst_sd(j, :) = nanstd(horzcat(exfull.Trials(ind).powstim), 0, 2);
    j = j+1;
end



end




