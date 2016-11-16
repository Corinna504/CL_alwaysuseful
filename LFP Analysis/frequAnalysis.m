function ex = frequAnalysis( ex, varargin )
% filters and interpolates lfp traces and returns their the ex file also
% containing the filtered, interpolated and power spectra
%
% optional input variables are:
% fs : sampling frequency
% notchf : notch filtered frequency
% notchq : quality value for filtering (the higher the narrower)
% lowpf:   low pass filtered frequency
% lowporder: low pass filter order
% nw    : time bandwidth product
%
% note that fs must be the first additional input because filter frequency
% are transformed from Hz to ?? via the sampling frequency.


% notch filter variables
Fs = 1000;              % sampling frequency
notchf = [50 50]/(Fs/2);     % notch filter frequency
notchord = 2;           % filter order

lowpf = 150/(Fs/2);     % lowpass filter cutoff frequency
lowpord = 3;            % filter order

% power spectrum in Chalk et al. time halfbandwidth was 3 and k was 5
nw = 2;         % time half bandwidth product


% parse input
k = 1;
while k<=length(varargin)
    switch varargin{k}
        case 'fs'
            Fs = varargin{k+1};
        case 'notchf'
            notchf = varargin{k+1}./ (Fs/2);
        case 'notchord'
            notchord = varargin{k+1};
        case 'lowpf'
            lowpf = varargin{k+1} / (Fs/2);
        case 'lowpord'
            lowpord = varargin{k+1};
        case 'nw'
            nw = varargin{k+1};
    end
    k=k+2;
end
clearvars k;

% notch filter
[b_notch,a_notch] = butter(notchord, notchf, 'stop' );
[b_notch2,a_notch2] = butter(4, notchf.*2, 'stop' );
% lowpass filter
% [b_lowp, a_lowp] = butter(lowpord,[ 0.0014, lowpf], 'bandpass');
% [b_lowp, a_lowp] = butter(lowpord, 0.001, 'high');
[b_lowp, a_lowp] = butter(lowpord, lowpf);

% perform functions on each trial lfp
for ind = 1:length(ex.Trials)
   
    %%% highpass filter by first subtracting the mean between -0.05 to 0.02s
    t_strt = ex.Trials(ind).Start - ex.Trials(ind).TrialStart;
    
    ts = ex.Trials(ind).LFP_ts - t_strt(1);
    highpassfilt = ex.Trials(ind).LFP - ...
        mean(ex.Trials(ind).LFP(ts>=-0.05 & ts<=0));


    %%% lowpass and notch filter
    lowpassfilt = filtfilt(b_lowp, a_lowp, highpassfilt);
    bandstop50 = filtfilt(b_notch, a_notch, lowpassfilt);
    ex.Trials(ind).LFP_filt = filtfilt(b_notch2, a_notch2, bandstop50);
    
    %%% interpolate the time of stimulus presentation
    time = t_strt(1)-0.05:1/Fs:t_strt(1)+0.45;
    interstim = interp1(ex.Trials(ind).LFP_ts, ex.Trials(ind).LFP_filt, time);
    
    %%% mutli taper approach
    % power spectrum density returned by pmtm is normalized per unit frequency
    [ex.Trials(ind).POW, ex.Trials(ind).FREQ] = ...
        pmtm(interstim(time>=0), nw, 2^nextpow2(sum(time>=0)), Fs);
    
    ex.Trials(ind).LFP_interp = interstim;
    ex.Trials(ind).LFP_interp_time = time-t_strt(1);
end

end

