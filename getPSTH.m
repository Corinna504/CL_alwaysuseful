function [psth, t] = getPSTH(T)
% returns the psth normalized to spks/s and corresponding time vector
% 
% takes a struct of trials from a classical ex.mat file and converts the
% spikes to a psth. Time bin width is 1ms.
%
% @Corinna Lorenz, 24.08.2016

fs = 1000; 

allspk = []; 
for i = 1:length(T)
    % preallocate variables
    frameon = T(i).Start - T(i).TrialStart;   % frame start times
    ts(i) = frameon(1);                                 % first frame                      
    te(i) = frameon(end) + mean(diff(frameon));         % last frame ending

    % spikes within the presentation time
    spks = T(i).Spikes ( T(i).Spikes >= ts(i) & T(i).Spikes <= te(i) );
    allspk = [allspk; spks-ts(i)] ;    % align to stimulus onset
end

% time bin vector
t = 1/fs: 1/fs :round(mean(te-ts)*1000)/1000;

% compute psth
psth = histc(allspk, t); 
psth = psth ./ length(T) .*fs; %convert to spk/s
if isempty(psth); psth=zeros(length(t),1); end
if size(psth,2)>1; psth=psth'; end
if mod(length(psth), 2); psth = psth(1:end-1); t = t(1:end-1); end

