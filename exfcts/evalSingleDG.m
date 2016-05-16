function [ex, argout] = evalSingleDG( exinfo, fname )
% batch file that calls all functions to evaluated drifiting gratings
% trials


% load raw data
ex = loadCluster( fname );
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);


%% LFP
fname_lfp = strrep(fname, exinfo.cluster, 'lfp');
if exist(fname_lfp)
    [powstim_mn, powstim_sd, powbase_mn, powbase_sd] = ...
        frequAnalysis(exinfo,  fname_lfp );
else
    powstim_mn = 0;    powstim_sd = 0;    powbase_mn = 0;     powbase_sd = 0;
end



%% Cluster Correlation

%%% Fano Factors
%     [ ff.classic, ff.fit, ff.mitchel, ff.church ] = ...
%         FanoFactors( ex, [spkstats.mn], [spkstats.var], info.param1);
ff = [];

fnamec0 = strrep(fname, exinfo.cluster, 'c0'); % load cluster 0
exc0 = loadCluster( fnamec0 );
exc0.Trials = exc0.Trials([exc0.Trials.me] == exinfo.ocul);

%%% z normed spike rates entered in ex.Trials
[ex, spkstats] = znormex(ex, exinfo, true);

%%% Noise Correlation
[exc0, spkstatsc0] = znormex(exc0, exinfo, true); % z norm
[rsc, prsc] = corr([ex.Trials.zspkrate]', [exc0.Trials.zspkrate]', 'rows', 'complete');

%%% Signale Correlation
[rsig, prsig] = corr([spkstats.mn]', [spkstatsc0.mn]', 'rows', 'complete');
    

%% Mean and Variance
if strcmp(exinfo.param1, 'or') 
    fitparam = fitgaussOR(spkstats);
else
    fitparam = [];
end

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
eX = -10^3;
eY = -10^3;



%% assign output arguments
argout =  {'fitparam', fitparam, ...
    'rateMN', [spkstats.mn], 'rateVARS', [spkstats.var], ...
    'ratePAR', [spkstats.(exinfo.param1)], 'rateSME', [spkstats.sd], ...
    'rsc', rsc, 'prsc', prsc, ...
    'rsig', rsig, 'prsig', prsig, ...
    'ff', ff, 'tcdiff', tcdiff, ...
    'powst_mn', powstim_mn, 'powst_sd', powstim_sd, ...
    'powbs_mn', powbase_mn, 'powbs_sd', powbase_sd, ...
    'ed', ed, 'eX', eX, 'eY', eY};
end



%%
function fitparam = fitgaussOR(spkstats)

% CL fit
[fitparam, ~, val]      = fitgauss( [spkstats.mn], [spkstats.sd], [spkstats.or] );

% HN fit
[fitHN,~,~,~,~,~]         = FitGauss_HN(val.uqang, val.mn, 'lin');
[fitHN.mean, val.uqang]   = unwrapdeg(fitHN.mean, val.uqang);

% CL fit with HN parameters
[fitparam, gaussr2, val] = fitgauss( [spkstats.mn], [spkstats.sd], [spkstats.or], fitHN, val);

fitparam.r2 = gaussr2;
fitparam.HN = fitHN;
fitparam.val = val;

end


function [ex, spkstats] = znormex(ex, exinfo, norm_flag)
%znormex
% converts spike rates to z-normed data for each condition pair
% norm_flag determines if to use spike rate (norm_falg = 1) or spike count
% (norm_flag = 0)

param1 = exinfo.param1;
parvls = unique( [ ex.Trials.(param1) ] );

j = 1;

if exinfo.isadapt
    time = 0:0.001:5;
else 
    time = 0:0.001:0.5;
end

for par = parvls
    
    % z-scored spikes for this stimulus
    ind = par == [ ex.Trials.(param1) ];
    
    if norm_flag
        z = zscore( [ ex.Trials(ind).spkRate ] );
        spkstats(j).(param1) = par;
        spkstats(j).mn  = mean([ex.Trials(ind).spkRate]);
        spkstats(j).var = var([ex.Trials(ind).spkRate]);
        spkstats(j).sd = std([ex.Trials(ind).spkRate]) / sqrt( sum(ind) );
    else
        z = zscore( [ ex.Trials(ind).spkCount ] );
        spkstats(j).(param1) = par;
        spkstats(j).mn  = mean([ex.Trials(ind).spkCount]);
        spkstats(j).var = var([ex.Trials(ind).spkCount]);
        spkstats(j).sd = std([ex.Trials(ind).spkCount])/ sqrt( sum(ind) );
    end
    
    if ~any(z)
        z = nan(length(z), 1);
    end
    z = num2cell(z);
    [ex.Trials(ind).zspkrate] = deal(z{:});
    
    
    % raster - contains 0 for times without spike and 1 for times of spikes
    % is reduced for times between -0.5s and 0.5s around stimulus onset
    idxct = find(ind);
    ct = ex.Trials(idxct);    % current trials
    
    ex.trials_n(j) = sum(ind);
    ex.raster{j,1} = zeros(length(ct), length(time));
    ex.rastercum{j,1} = nan(length(ct), length(time));
        
    
    for k = 1:length(idxct)
        
        t_strt = ct(k).Start - ct(k).TrialStart;
        if exinfo.isadapt
            t_strt = t_strt(t_strt<=5);
        end
        
                
        idx = round((ct(k).Spikes(...
            ct(k).Spikes>=t_strt(1) & ct(k).Spikes<=t_strt(end))-t_strt(1)) ...
            *1000);
        
        idx(idx==0) = 1; % avoid bad indexing
        
        
        ex.raster{j}(k, idx) = 1;
        ex.rastercum{j}(k, idx) = k;
    end
    
    j = j+1;
    
end

ex.raster_pval = parvls;

end





