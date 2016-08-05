function [ex, argout] = evalSingleRC( exinfo, fname )
% counterpart to evalSingleDG but specified for reverse correlation trials



% load raw data
ex = loadCluster( fname );
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);


%% Mean and Variance
ex_ = load( fname ); ex =ex_.ex;
[ res, spkstats, fitparam ] = RCsubspace(ex);

res = getLat2D(res, exinfo);



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



function res = getLat2D(res, exinfo);



psth = res.sdfs.psth;
n_or = size(psth, 1);

[~, co_idx] = sort(res.sdfs.y(1,:));
n_co = size(psth, 2);

h = findobj('Tag', 'latency');
if isempty(h)
    figure('Tag', 'latency');
    col = 'r';
else
    set(h, 'Tag', 'done latency');
    figure(h);
    col = 'b';
end

for or = 1:n_or
    kk = 1;
    for co = co_idx
        
       [lat2hmax_orco(or,kk), latfp_orxco(or, kk), pPoisson(or, kk)] =...
           CL_newLatency_helper(res.sdfs.s{or,co}, -20:0.1:160);
       
        subplot(n_or, n_co, kk+ (or-1)*n_co); hold on;
        plot(0:0.1:160, res.sdfs.s{or,co}(201:end), 'Color', col); hold on;
        
        plot([latfp_orxco(or,kk) latfp_orxco(or,kk)], get(gca, 'YLim'), 'k' )
        xlim([0,160]);
        kk = kk+1;
    end
end

res.latfp_xco = latfp_orxco;
res.latfp_pPoisson_xco = pPoisson;
res.lat2hmax_xco = lat2hmax_orco;



h = findobj('Tag', 'done latency');
if ~isempty(h)
    set(h, 'Name', exinfo.figname);
    savefig(h, exinfo.fig_raster);
end
end



function [lat2hmax, latfp, pPoisson] = CL_newLatency_helper(sdf, times)

lat2hmax     = -1;
dur     = -1;
latfp   = -1;
pPoisson = 0;
noise   = mean(sdf(200:400)); 

if max(sdf)>mean(noise)*3.5
    
    sdf2 = sdf-noise;     % normalizer for baseline variability
    
    % first time of half max of response
    idx = find( sdf2 >= (max(sdf2)/2), 1, 'first');  
    lat2hmax = times(idx)/10;
    
    [latfp, ~, pPoisson] = friedmanpriebe(round(sdf(200:end)), ...
        'minTheta', 250);
    latfp = latfp/10;
end

end

