function [ churchland_info ] = fctChurchland( info )
%fctChurchland
% Trials without reward are excluded. Each neuron in each condition is one
% date point.
%



addTime = 0.200;


% ex files for valid trials (TODO other criteria? valid depends on gain
% fit)

%% serotonin
ex_base = {info([info.valid]==1 & [info.is5HT]).ex1};
ex_drug = {info([info.valid]==1 & [info.is5HT]).ex_drug1};
parType = {info([info.valid]==1 & [info.is5HT]).param1};

% GET INFO IN DATA STRUCTURE SUCH THAT IT CAN BE PASSED TO VarsVsMean
churchland_info_base = getInfo4Ex(ex_base , parType, addTime);
churchland_info_drug = getInfo4Ex(ex_drug, parType, addTime);

churchland_info.base5HT = churchland_info_base;
churchland_info.serotonin = churchland_info_drug;



%% nacl
ex_base = {info([info.valid]==1 & ~[info.is5HT]).ex1};
ex_drug = {info([info.valid]==1 & ~[info.is5HT]).ex_drug1};
parType = {info([info.valid]==1 & ~[info.is5HT]).param1};

% GET INFO IN DATA STRUCTURE SUCH THAT IT CAN BE PASSED TO VarsVsMean
churchland_info_base = getInfo4Ex(ex_base , parType, addTime);
churchland_info_drug = getInfo4Ex(ex_drug, parType, addTime);

churchland_info.baseNaCl = churchland_info_base;
churchland_info.NaCl = churchland_info_drug;


end


function [c_info] = getInfo4Ex(x, parType, addTime)

idx = 1;
c_info = struct('neuronID', [], 'is5HT', [], 'par', [], 'parval', [], 'spikes', []);

for i = 1:length(x)
    
    Trials = x{i}.Trials;
    Trials = Trials([Trials.Reward]==1);
    
    par = parType{i};
    eval(['parval = unique([Trials.' par ']);'])
    
    
    
    for j = 1:length(parval)
        
        eval(['curTrials = Trials([Trials.' par '] == parval(j));']);
        
        
        c_info(idx).neuronID = x{i}.SessionID;
        c_info(idx).par = par;
        c_info(idx).parval = parval(j);
        
        
        
        for k = 1:length(curTrials)
            
            t_frame = curTrials(k).Start - curTrials(k).TrialStart;
            t_start = t_frame(1);
            t_end = t_frame(end) + mean(diff(t_frame));
            t_before = t_start - addTime;
            t_after = t_end + addTime;
            
            
            spk_before = round((curTrials(k).SpikesC1(curTrials(k).SpikesC1 >= t_before &...
                curTrials(k).SpikesC1 <= t_start) -t_before)  *1000)+1;
            
            
            spk_pres = round((curTrials(k).SpikesC1(curTrials(k).SpikesC1 > t_start &...
                curTrials(k).SpikesC1 <= t_end) -t_before) *1000)+1;
            
            spk_after = round((curTrials(k).SpikesC1(curTrials(k).SpikesC1 > t_end &...
                curTrials(k).SpikesC1 <= t_after) -t_before) *1000)+1;
            
            
            % if the trial length is shorter than 460 ms
            % the time after trial is postponed, e.g. addtional
            % entries with 0 are added in the time between
            dur_pres = round((t_end-t_start) *1000);
            if dur_pres < 460
                diff_ = 460 - dur_pres;
                spk = [spk_before', spk_pres', spk_after'+diff_];
            elseif dur_pres > 460
                warning('presentation duration is longer than 0.46');
                diff_ = dur_pres - 460;
                spk = [spk_before', spk_pres(spk_pres <= 460)', spk_after'-diff_];
            else
                spk = [spk_before', spk_pres', spk_after'];
            end
            
            if (parval(j) == 22.5)
                fprintf('ex %1.0f, ParVal %3.0f, curTrial %1.0f \n', i, parval(j), k)
            end
            
            
            c_info(idx).spikes(k,1:(460+1+2000*addTime)) = false;
            c_info(idx).spikes(k,spk) = true;
            
            if size(c_info(idx).spikes, 2) > 861
              warning();  
            end
            
            
        end
        
        
        idx = idx+1;
    end
    
end

end