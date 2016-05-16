function ex = loadCluster(fname, onlyrewarded_flag)
% all preprocessing goes here

if nargin == 1
    onlyrewarded_flag = 1;
end


load(fname);


% collapse orientations to [0 180]
if isfield(ex.Trials, 'or')
    trials = mod([ex.Trials.or], 180)'; trials = num2cell(trials);
    idx = [ex.Trials.or]<=360;
    [ex.Trials(idx).or] = deal(trials{idx});
end

% pupil sizes 
if isempty(strfind(fname, 'c0')) && isempty(strfind(fname, 'lfp'))
    [~, ex.Trials] = fctPupilSizeTrial(ex, fname, 0);
end


% add blank
addBlank;


if onlyrewarded_flag
    ex.Trials = ex.Trials([ex.Trials.Reward] == 1);   
end


if isempty(strfind(fname, 'lfp'))
    addspkRate;  
end



