function dat = fctPupilSizeTrialMN(ex)

% only binocular trials
i_incl = ([ex.Trials.me]==0);
oTrials = ex.Trials(i_incl); %([ex.Trials.me]==0);

fc = 20; %cutoff frequency in Hz
[b,a] = butter(3, fc*2/500);

if isempty(oTrials)
    dat.info = 'no binocular trials';
else
    
    V3 = {};
    T = {};
    

    col = lines(4);
    j = 1;
    t = [];
    v3 = [];
    seq_strt = nan;
    
    for i=1:length(oTrials)
       
        n = oTrials(i).Eye.n;
        
        if oTrials(i).Reward ~= 0
            if isnan(seq_strt)
                seq_strt = oTrials(i).TrialStartDatapixx + ...
                    (oTrials(i).Start(1) - oTrials(i).TrialStart);
            end
            
            
            t = [t, oTrials(i).Eye.t(1:n) - seq_strt];
            v3 = [v3, oTrials(i).Eye.v(3, 1:n)];
           
            j=j+1;
            
        end
            
        if oTrials(i).RewardSize>0.1 || oTrials(i).Reward == 0
            v3 = filtfilt(b,a, v3);
            j=1;
            if ~isempty(v3)
                V3 = [V3, {v3}];
                T = [T, {t}];
            end
            v3 = []; t=[];
            seq_strt =nan; 
        end        
        
    end
    
    
    [V3_new, t_new] = meanTraj(T, V3);
    
    V3_new = cell2mat(V3_new')';
    mn = nanmean(V3_new,2);
    
    for kk=1:size(V3_new, 2)
        plot(t_new, V3_new(:, kk)-mn); hold on;
    end
%     plot(t_new, mn, 'r');
    
    dat.info = 'only binocular data';

    
end
end



function LinePressed(line_h, eventdata, trial)
    trial
end




function [V3_new, t_new] = meanTraj(T, V3)


minT = min(cell2mat(T));
maxT = max(cell2mat(T));
t_new = minT:0.002:maxT;

V3_new = cellfun(@(v3, t) interp1(t, v3, t_new), V3, T, 'UniformOutput', false);
cell2mat(V3_new);

end


