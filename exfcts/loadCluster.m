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

% add blank
addBlank;


% collapse orientations to [0 180]
if strcmp(ex.exp.e1.type, 'or')
    trials = mod([ex.Trials.or], 180)'; trials = num2cell(trials);
    idx = [ex.Trials.or]<=360;
    [ex.Trials(idx).or] = deal(trials{idx});
elseif strcmp(ex.exp.e1.type, 'co')

    co = [ex.Trials.co]';  % take contrast values and replace 0 contrast with blank value
    co(co==0)= ex.exp.e1.blank;  
    co = num2cell(co);
    [ex.Trials.co] = deal(co{:});
end
% pupil sizes 
if isempty(strfind(fname, 'c0')) && isempty(strfind(fname, 'lfp'))
%     [~, ex.Trials] = fctPupilSizeTrial(ex, fname, p_flag);
end




if onlyrewarded_flag
    ex.Trials = ex.Trials([ex.Trials.Reward] == 1);   
end


if isempty(strfind(fname, 'lfp'))
    addspkRate;  
end



