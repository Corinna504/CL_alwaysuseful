function [ex, varargout] = frequAnalysis( ex, varargin )
% filters and interpolates lfp traces and returns their power spectra
% 
% optional input variables are:
% fs : sampling frequency
% filterf : notch filtered frequency
% filterq : quality value for filtering (the higher the narrower)
% nw    : time bandwidth product
% time  : time window considered for analysis as a vector
% timeplot  : plot lfp in time domain
% powplot  : plot lfp in frequ domain


% note that fs, filterf, filterq must be forwarded in that particular
% order


% set time bin
time = 0:0.001:0.45;

% notch filter variables
Fs = 1000;              % sampling frequency
wo = 50/(Fs/2);         % to be filtered frequency
bw = wo/25;             % 50Hz / quality factor




% power spectrum in Chalk et al. time halfbandwidth was 3 and k was 5
nw = 2;         % time half bandwidth product


% parse input
k = 1;  powplot_flag= false;  timeplot_flag = false;
while k<=length(varargin)
    switch varargin{k}
        case 'fs'
            Fs = varargin{k+1};
        case 'filterf'
            wo = varargin{k+1}/ (Fs/2);
        case 'filterq'
            bw = wo/varargin{k+1};
        case 'nw'
            nw = varargin{k+1};
        case 'time'
            time = varargin{k+1};
        case 'timeplot'
            timeplot_flag = varargin{k+1};
        case 'powplot'
            powplot_flag = varargin{k+1};
    end
    k=k+2;
end
clearvars k;

% notch filter
[b,a] = iirnotch(wo,bw);
% lowpass filter
[butter_b,butter_a] = butter(6,0.4);


% perform functions on each trial lfp
for ind = 1:length(ex.Trials)
    
    if isempty(ex.Trials(ind).LFP) || all(ex.Trials(ind).LFP_ts < 0) || ...
            ~any(ex.Trials(ind).LFP_ts >= 0.48)
        ex.Trials(ind).pow = nan(257, 1);
        ex.Trials(ind).LFP_interp = [];
    else
        
        %%% filter 50Hz
        lowpassfilt = filtfilt(butter_b, butter_a, ex.Trials(ind).LFP);
        ex.Trials(ind).LFP_filt = filter(b, a, lowpassfilt);
        ex.Trials(ind).LFP_interp = ...
            interp1(ex.Trials(ind).LFP_ts, ex.Trials(ind).LFP_filt, time);
               
        
        %%%  get power spectrum
        %Sampled data in mV for inter stimulus time
        interstim   = ex.Trials(ind).LFP_interp;
        
        % mutli taper approach
        % power spectrum density returned by pmtm is normalized per unit frequency
        [ex.Trials(ind).POW, ex.Trials(ind).FREQ] = ...
            pmtm(interstim, nw, length(interstim), Fs);
        
    end
    
end  

% remvove files that did not contain LFP during stimuli presentation
ex.Trials = ex.Trials(  ~cellfun(@isempty, {ex.Trials.LFP_interp}) ); 


% show plots of LFP signal and power and get stimulus averaged results
% optional
varargout = {};

if powplot_flag
    
    h = findobj('tag', 'pow');
    
    if isempty(h)
        figure('tag', 'pow');
        subplot(1,2,1);
        title('baseline')
    else
        figure(h)
        subplot(1,2,2);
    end
    pow_avg = freqpow(ex);
    varargout = [varargout, {pow_avg}];

end

if timeplot_flag
    
    h = findobj('tag', 'lfp');
    
    if isempty(h)
        figure('tag', 'lfp');
        subplot(1,2,1);
        title('baseline')
    else
        figure(h)
        subplot(1,2,2);
    end
    
    lfp_avg = timelfp(ex, time);    
    varargout = [varargout, {lfp_avg}];
end
    
end


function lfp_avg = timelfp(ex, time)
% stimulus triggered average

[ param, vals] = getStimParam( ex );
col = lines(length(vals));

off0 =  max(horzcat(ex.Trials.LFP_interp));
maxoff = 0;

%%%
for i = 1:length(vals)
    
    off = off0;
    trials = ex.Trials([ex.Trials.(param)] == vals(i));
    lfp_avg(i,:) = nanmean(vertcat(trials.LFP_interp), 1);
    
    
    plot(time + (time(end)*(i-1)), ...
        lfp_avg(i,:)  -2*off0, ...
        'LineWidth', 2, 'Color', col(i, :)); hold on
    
   
    for k = 1:length(trials)
        
        i_raw = trials(k).LFP_ts <= time(end)  & trials(k).LFP_ts >= 0;
        plot(trials(k).LFP_ts(i_raw)+ (time(end)*(i-1)),...
            off + trials(k).LFP(i_raw), 'Color', [0.8 0.8 0.8], 'LineWidth', 2);
        
        plot(time + (time(end)*(i-1)), off +trials(k).LFP_interp, 'Color', col(i, :));
        
        off = off+off0;
    end
    
    maxoff = max([off, maxoff]);
end

ylim([-3*off0, maxoff + off0]);
xlim([0,time(end)*i]);
xlabel('time [s], lined up');
ylabel('lined up lfp signals ');
title('fat lines: amplifiied, averaged lfp');
box off
end


function pow_avg = freqpow(ex)
% stimulus triggered average

[ param, vals] = getStimParam( ex );
col = lines(length(vals));

fidx = 20:40;
f = ex.Trials(1).FREQ(fidx);
maxf = max( f ) - min( f ) ;

%%%
off0 =0; maxoff = 0;
for i = 1:length(ex.Trials)
    off0 = max( [off0; ex.Trials(i).POW(fidx)] );
end

%%%
for i = 1:length(vals)
    
    trials = ex.Trials([ex.Trials.(param)] == vals(i));
    pow_avg(i,:) = nanmean(horzcat(trials.POW),2);
    off = off0;
    
    plot(f + (maxf*(i-1)), pow_avg(i,fidx) -2*off0, ...
        'LineWidth', 2, 'Color', col(i, :)); hold on
    
    for k = 1:length(trials)
        plot(f + (maxf*(i-1)), off +trials(k).POW(fidx), 'Color', col(i, :));
        off = off+off0;
    end
    
    maxoff = max([off, maxoff]);
end

ylim([-3*off0, maxoff+off0]);
xlim([min(f), maxf*i+maxf]);
ax = gca; ax.YLim(2) = ax.YLim(2)-off0 ;
xlabel(sprintf('freq, lined up, range: [%1.0f, %1.0f]', min(f), max(f)));
ylabel('lined up lfp power ');
title('fat lines: amplifiied, averaged pow');
box off

end
