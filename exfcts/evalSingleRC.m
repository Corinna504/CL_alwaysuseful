function [ex, argout] = evalSingleRC( exinfo, fname )
% counterpart to evalSingleDG but specified for reverse correlation trials



% load raw data
ex = loadCluster( fname );
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);


%% LFP
% fname_lfp = strrep(fname, exinfo.cluster, 'lfp');
% if exist(fname_lfp)
%     [powstim_mn, powstim_sd, powbase_mn, powbase_sd] = ...
%         frequAnalysis(exinfo,  fname_lfp );
% else
    powstim_mn = 0;    powstim_sd = 0;    powbase_mn = 0;     powbase_sd = 0;
% end



%% Mean and Variance
ex_ = load( fname ); ex =ex_.ex;
[ res, spkstats, fitparam ] = RCsubspace(ex);


%% tc height diff
minspk = min([spkstats.mn]);
maxspk = max([spkstats.mn]);
tcdiff = (maxspk - minspk) / mean([maxspk, minspk]);

%% Electrode Information
if isfield(ex.Trials(1), 'ed')
    ed = ex.Trials(1).ed;
else
    ed = -1;
end
eX = -10^3;eY = -10^3;


%% assign output arguments
argout =  {'lat', res.latFP, 'lat2Hmax', res.lat, 'fitparam', fitparam, ...
    'rateMN', [spkstats.mn], 'rateVARS', [spkstats.var], ...
    'ratePAR', [spkstats.(exinfo.param1)], 'rateSME', [spkstats.sd], ...
    'tcdiff', tcdiff, 'resvars', res.vars2, 'sdfs', res.sdfs,...
    'resdur', res.dur,  'times', res.times, ...
    'powst_mn', powstim_mn, 'powst_sd', powstim_sd, ...
    'powbs_mn', powbase_mn, 'powbs_sd', powbase_sd, ...
    'ed', ed, 'eX', eX, 'eY', eY};
end


