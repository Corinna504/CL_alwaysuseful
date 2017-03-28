
% 
% add...
% - ...number of spikes
% - ...number of presented frames
% - ...spike rate
% 
% @author Corinna Lorenz
% @created 22.09.2015
% @lastchanged 22.09.2015


for n = 1:length(ex.Trials)
      
    t_spks = ex.Trials(n).Spikes; % time of spike occurance
    t_strt = ex.Trials(n).Start - ex.Trials(n).TrialStart; % stimuli presentation starts
    
    if ex.stim.vals.adaptation
        ex.Trials(n).adapt = true;
        ex.Trials(n).adaptationDuration = ex.stim.vals.adaptationDur;
        t_strt = t_strt(t_strt > ex.stim.vals.adaptationDur);
    else
        ex.Trials(n).adapt = false;
        ex.Trials(n).adaptationDuration = 0;
    end

    if length(t_strt) >= 1 % spikes in the interval of stimuli presentation        
        t_end = t_strt(end);
        
        frame_dur = mean(diff(t_strt));
        ex.Trials(n).nFrames    = t_end - t_strt(1);
%         t_end - t_strt(1)
        ex.Trials(n).nSpks      = length(find( t_spks>=t_strt(1) & t_spks<=t_end));
     
        if length(ex.Trials(n).Start) == 46
            ex.Trials(n).spkRate    =  ex.Trials(n).nSpks / (t_end - t_strt(1));
            ex.Trials(n).spkCount   =  ex.Trials(n).nSpks ;
        else
            ex.Trials(n).spkRate    =  ex.Trials(n).nSpks / (t_end - t_strt(1) + frame_dur);
            ex.Trials(n).spkCount   =  ex.Trials(n).nSpks ;
        end
        
        
        % I should correct for the temporal frequency because 
        % simple cells would have a disadvantage in cases of odd numbers of
        % circles presented. Yet, this is not simple. A frequency analysis
        % or something alike would have to be performed to retract the
        % spikes per cycle per second. Because we only consider pair-wise
        % comparisons, this is issue is neglected for now.
        
    else
        ex.Trials(n).spkRate = [];
    end
    
end


clearvars t_spks t_strt t_end n frame_dur