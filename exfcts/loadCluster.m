function ex = loadCluster(fname, varargin)
% all preprocessing goes here


p_flag = 0;
onlyrewarded_flag = 1;

j = 1;

while j<=length(varargin)
    switch varargin{j}
        case 'reward'
            onlyrewarded_flag = varargin{j+1};
        case 'p_flag'
            p_flag = varargin{j+1};
    end
    j=j+1;
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
    [~, ex.Trials] = fctPupilSizeTrial(ex, fname, p_flag);
end


% add blank
addBlank;


if onlyrewarded_flag
    ex.Trials = ex.Trials([ex.Trials.Reward] == 1);   
end


if isempty(strfind(fname, 'lfp'))
    addspkRate;  
end



