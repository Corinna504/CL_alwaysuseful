function dat = fctPupilSize2(ex)

% only binocular trials
oTrials = ex.Trials; %([ex.Trials.me]==0);

if isempty(oTrials)
    dat.info = 'no binocular trials';
else
    
    % concatenate all v3
    v3  = cellfun( @getV3, ...
        {oTrials.Eye}, ...
        'UniformOutput', false);
    
    t = cellfun( @getT, ...
        {oTrials.Eye}, {oTrials.TrialStartDatapixx}, ...
        {oTrials.TrialEndDatapixx}, ...
        'UniformOutput', false);
    
    rsz = cellfun(@getRSZ,...
        {oTrials.RewardSize}, t,...
        'UniformOutput', false);
    
    dat.t   = cell2mat(t);
    v3      = cell2mat(v3);
    dat.rsz = cell2mat(rsz);
    
    
    % filter all v3
    fc = 20; %cutoff frequency in Hz
    [b,a] = butter(3, fc*2/500);
    dat.v3 = filtfilt(b,a, v3);
   
    dat.med = median(v3);

    dat.info = sprintf('median: %3f', dat.med);
end

end



%-------------------------------------------------------------------------

function rsz_multiple = getRSZ(rsz_single, t)
rsz_multiple = zeros(size(t));
rsz_multiple(find(t>=0, 1, 'first')) = .1;
rsz_multiple(end) = rsz_single;
end

function t = getT(eye, trialstart, trialend)
dur = trialend - trialstart;
t = eye.t(1:eye.n) - trialstart;
end

function v3 = getV3(eye)
v3 = eye.v(3,1:eye.n);
end