function [dat] = fctFrequ(ex, varargin)



if nargin > 2
    error('requires at most 2 arguments');
end

defArgs = {'bandstop'}; % default for optional arguments
defArgs(1:nargin-1) = varargin;
if strcmp(defArgs{1}, 'bandstop') || strcmp(defArgs{1}, 'peak')
    [filteropt] = defArgs{:};
else
    error('wrong input value - decide between bandstop and peak deletion')
end


% filter settings
% adopted from ripple manual grapevine
% 2nd order butterworth filter
[b,a] = butter(2,  [49 51]./(1000/2), 'stop');
psrange = 2:200;


% other settings

% include blanks
e1_vals = [ex.exp.e1.vals, ex.exp.e1.blank]; %     e1_vals = ex.exp.e1.vals;
e2_vals = ex.exp.e2.vals;


% loop through all stimuli conditions for trials with equal conditions
for i = 1:length(e1_vals)
    ind1 = e1_vals(i) == [ex.Trials.(ex.exp.e1.type)];
    
    for j = 1:length(e2_vals)
        ind2 = e2_vals(j) == [ex.Trials.(ex.exp.e2.type)];
        
        dat((i-1)*length(e2_vals) +j).(ex.exp.e1.type) = e1_vals(i);
        dat((i-1)*length(e2_vals) +j).(ex.exp.e2.type) = e2_vals(j);
        dat((i-1)*length(e2_vals) +j).idx = ind1&ind2;
        
    end
end

clearvars i j defArgs ind1 ind2;


%% z score trials with equal conditions
time = -0.499:0.001:0.5;
for ind = 1:length(dat)
    
    cLFP        = {ex.Trials(dat(ind).idx).LFP};
    cLFP_ts     = {ex.Trials(dat(ind).idx).LFP_ts};
    
    cLFP = cLFP(~cellfun(@isempty, cLFP_ts));
    cLFP_ts = cLFP_ts(~cellfun(@isempty, cLFP_ts));
    
    if isempty(cLFP_ts)
        warning(['skipped file ' fname ' because lfp file was empty']);
        continue
    end
    
    
    %%% interpolated time series to 1000 data points ( = sample frequency )
    interpTS  = cell2mat(cellfun( ...
        @interp1, cLFP_ts, cLFP, repmat({time}, size(cLFP)),...
        'UniformOutput', false)')';
    
    % corresponding power spectrum
    interpPS = abs(fft(interpTS));           
    
    
    %%% filter 50Hz utility frequency
    % comment: first non-zero frequency is at index = 2
    
    switch filteropt
        
        case 'bandstop'
            filteredTS  = filtfilt(b,a, interpTS);

            y           = fft(filteredTS);
            filteredPS  = abs(y);
            ifftTS      = ifft(y);
            
            
        case 'peak'
            y           = fft(interpTS);
            theta       = angle(y);                     clearvars i;
            r           = abs(y);               r(51, :)  = 0;
            z           = r.* exp(1i*theta);    z(949, :) = conj(z(51, :));
            
            filteredPS  = r;
            filteredTS  = real(ifft(z));
            ifftTS      = ifft(z);
            
    end
    
    % determine time stamps and zscored data
    dat(ind).interpTS   = interpTS;                     % time series signal
    dat(ind).interpPS   = interpPS(psrange, :);         % power spectrum
    dat(ind).rangeTS    = time;                         % recording time 
    dat(ind).rangePS    = psrange;
    
    dat(ind).filtTS     = filteredTS;
    dat(ind).filtPS     = filteredPS(psrange, :);
    dat(ind).filtIFFT   = ifftTS;
    
    dat(ind).znorm       = zscore(dat(ind).filtTS);
    
    
end


end







