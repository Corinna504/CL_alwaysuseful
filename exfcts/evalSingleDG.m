function [ex, argout] = evalSingleDG( exinfo, fname )
% batch file that calls all functions to evaluated drifiting grating trials



ex = loadCluster( fname ); % load raw data
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);


%% Anova for selectivity

if strcmp(exinfo.param1, 'co')
    idx_nonblank = [ex.Trials.(exinfo.param1)] ~= ex.exp.e1.blank & ...
            [ex.Trials.(exinfo.param1)] ~= 0;
else
    idx_nonblank = [ex.Trials.(exinfo.param1)] < ex.exp.e1.blank;
end

p_anova = anova1([ex.Trials(idx_nonblank).spkRate], ...
    [ex.Trials(idx_nonblank).(exinfo.param1)],'off');

%% Spiking

%%% z normed spike rates entered in ex.Trials


%%% Fano Factors
% results for the second half
ex.Trials = ex.Trials(ceil(length([ex.Trials])/2):end);
[ex, spkrate, spkcount] = znormex(ex, exinfo);

[ ff.classic_2ndhalf, ff.fit_2ndhalf, ff.mitchel_2ndhalf, ff.church_2ndhalf ] = ...
    FanoFactors( ex, [spkcount.mn], [spkcount.var], exinfo.param1);

%%% Fano Factors 
% results for all data
ex = loadCluster( fname ); % load raw data
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);
[ex, spkrate, spkcount] = znormex(ex, exinfo);


[ ff.classic, ff.fit, ff.mitchel, ff.church ] = ...
    FanoFactors( ex, [spkcount.mn], [spkcount.var], exinfo.param1);




%% assign output arguments
argout =  { 'ff', ff};
return 
%%

%%% Cluster Analysis
fnamec0 = strrep(fname, exinfo.cluster, 'c0'); % load cluster 0
exc0 = loadCluster( fnamec0 );
exc0.Trials = exc0.Trials([exc0.Trials.me] == exinfo.ocul);

%%% Noise Correlation
[exc0, spkstatsc0] = znormex(exc0, exinfo, rate_flag); % z norm
[rsc, prsc] = corr([ex.Trials.zspkrate]', [exc0.Trials.zspkrate]', 'rows', 'complete');

%%% Signale Correlation
[rsig, prsig] = corr([spkrate.mn]', [spkstatsc0.mn]', 'rows', 'complete');


%% Fitting
if strcmp(exinfo.param1, 'or')
    fitparam = fitOR( [spkrate.mn], [spkrate.sd], [spkrate.or] );
    
elseif strcmp(exinfo.param1, 'co')
    
    fitparam = fitCO([spkrate.mn], [spkrate.(exinfo.param1)]);

    % check for underspampling
    i_cosmc50 = [ex.Trials.(exinfo.param1)]<=fitparam.c50 & idx_nonblank;
    fitparam.undersmpl(1) = anova1([ex.Trials(i_cosmc50).spkRate], [ex.Trials(i_cosmc50).(exinfo.param1)],'off');
    
    i_cohic50 = [ex.Trials.(exinfo.param1)]>fitparam.c50 & idx_nonblank;
    fitparam.undersmpl(2) = anova1([ex.Trials(i_cohic50).spkRate], [ex.Trials(i_cohic50).(exinfo.param1)],'off');

    
    if strfind( fname , exinfo.drugname )
        fitparam.sub = fitCO_drug([spkrate.mn], [spkrate.(exinfo.param1)], exinfo.fitparam);
    end
    
elseif strcmp(exinfo.param1, 'sz')
    fitparam = fitSZ([spkrate.mn], [spkrate.sd], [spkrate.(exinfo.param1)]);
    
elseif strcmp(exinfo.param1, 'sf')
    fitparam_lin = fitSF([spkrate.mn], [spkrate.sd], [spkrate.(exinfo.param1)], false);
    fitparam_log = fitSF([spkrate.mn], [spkrate.sd], [spkrate.(exinfo.param1)], true);
  
    
    % first entry linear fit, second entry log scaled fit
    fitparam.others = {fitparam_lin; fitparam_log};
    
else
    fitparam = [];
end

%% tc height diff
minspk = min([spkrate.mn]);
maxspk = max([spkrate.mn]);
tcdiff = (maxspk - minspk) / mean([maxspk, minspk]);


%% Phase selectivity
phasesel = getPhaseSelectivity(ex, 'stim', exinfo.param1);


%% assign output arguments
argout =  {'fitparam', fitparam, ...
    'rateMN', [spkrate.mn]', 'rateVARS', [spkrate.var]', ...
    'ratePAR', [spkrate.(exinfo.param1)]', 'rateSME', [spkrate.sd]', ...
    'rsc', rsc, 'prsc', prsc, ...
    'rsig', rsig, 'prsig', prsig, ...
    'ff', ff, 'tcdiff', tcdiff, ... 
    'nrep', [spkrate.nrep]', ...
    'phasesel', phasesel, 'p_anova', p_anova};
end



