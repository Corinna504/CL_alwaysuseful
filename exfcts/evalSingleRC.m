function [ex, argout] = evalSingleRC( exinfo, fname )
% counterpart to evalSingleDG but specified for reverse correlation trials



% load raw data
ex = loadCluster( fname );
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);


%% Mean and Variance
ex_ = load( fname ); ex =ex_.ex;
[ res, spkstats, fitparam ] = RCsubspace(ex);


%% tc height diff
minspk = min(spkstats.mn);
maxspk = max(spkstats.mn);
tcdiff = (maxspk - minspk) ./ mean([maxspk, minspk]);

%% Electrode Information
if isfield(ex.Trials(1), 'ed')
    ed = ex.Trials(1).ed;
else
    ed = -1;
end
eX = -10^3;eY = -10^3;


%% assign output arguments
argout =  {'lat', res.latFP, 'lat2Hmax', res.lat, 'fitparam', fitparam, ...
    'rateMN', spkstats.mn, 'ratePAR', spkstats.or, 'rateSME', spkstats.sem, ...
    'tcdiff', tcdiff, 'resvars', res.vars2, 'sdfs', res.sdfs,...
    'resdur', res.dur,  'times', res.times, ...
    'ed', ed, 'eX', eX, 'eY', eY};
end


