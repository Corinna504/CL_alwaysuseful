function [ex, argout] = evalSingleDG( exinfo, fname )
% batch file that calls all functions to evaluated drifiting grating trials

argout = {};

%% Load data
ex = loadCluster( fname, 'ocul', exinfo.ocul ); % load raw data
[ex, spkrate, spkcount] = znormex(ex, exinfo);


%% Duration of the experiment
expduration = ex.Trials(end).TrialEnd - ex.Trials(1).TrialStart;

%% Selectivity measured by Anova
p_argout = SelectivityCheck(exinfo, ex);
argout = [argout p_argout{:}];

%% Fano Factor
% ff_argout = FF(exinfo, ex);
% argout = [argout ff_argout{:}];

%% Noise correlation and signal correlation
rsc_argout = getRsc(exinfo, fname);
argout = [argout rsc_argout{:}];

%% Tuning curve fit
tc_argout = fitTC(exinfo, spkrate, ex, fname);
argout = [argout tc_argout{:}];

%% Tc height diff
minspk = min([spkrate.mn]);
maxspk = max([spkrate.mn]);
tcdiff = (maxspk - minspk) / mean([maxspk, minspk]);
argout = [argout {'tcdiff', tcdiff}];


%% Phase selectivity
phasesel = getPhaseSelectivity(ex, 'stim', exinfo.param1);
argout = [argout {'phasesel', phasesel}];

%% assign output arguments
argout =  [argout {'rateMN', [spkrate.mn]', 'rateVARS', [spkrate.var]', ...
    'ratePAR', [spkrate.(exinfo.param1)]', 'rateSME', [spkrate.sem]', ...
    'rateSD', [spkrate.sd]', 'rawspkrates', [spkrate.sd]', ...
    'rate_resmpl', {spkrate.resamples}, ...
    'nrep', [spkrate.nrep]', ...
    'expduration', expduration}];

end
    
    


%% Cluster Analysis
function rsc_argout = getRsc(exinfo, fname)

% load data
ex = loadCluster(fname, 'ocul', exinfo.ocul );

fnamec0 = strrep(fname, exinfo.cluster, 'c0'); % load cluster 0
exc0 = loadCluster( fnamec0, 'ocul', exinfo.ocul );


%%% all trials
[ex, spkrate] = znormex(ex, exinfo);
[exc0, spkrate_c0] = znormex(exc0, exinfo); % z norm

% Noise Correlation
[rsc, prsc] = corr([ex.Trials.zspkcount]', [exc0.Trials.zspkcount]', 'rows', 'complete');
% Signale Correlation
[rsig, prsig] = corr([spkrate.mn]', [spkrate_c0.mn]', 'rows', 'complete');

trials = struct('spkRate', [ex.Trials.spkRate], 'zspkCount', [ex.Trials.zspkcount], 'param',[ex.Trials.(exinfo.param1)]);
trials0 = struct('spkRate', [exc0.Trials.spkRate], 'zspkCount', [exc0.Trials.zspkcount], 'param',[exc0.Trials.(exinfo.param1)]);


rsc_all = {'rsc', rsc, 'prsc', prsc, 'rsig', rsig,...
    'prsig', prsig, 'c0geomn', geomean([mean([spkrate_c0.mn]), mean([spkrate.mn])]),...
    'trials_c0', trials0, 'trials_c1', trials};


%%% 2nd half
ex.Trials = getPartialTrials(ex.Trials); 
[ex, spkrate] = znormex(ex, exinfo);

exc0.Trials = getPartialTrials(exc0.Trials);
[exc0, spkrate_c0] = znormex(exc0, exinfo); % z norm

% Noise Correlation
[rsc, prsc] = corr([ex.Trials.zspkcount]', [exc0.Trials.zspkcount]', 'rows', 'complete');
% Signale Correlation
[rsig, prsig] = corr([spkrate.mn]', [spkrate_c0.mn]', 'rows', 'complete');

rsc_2nd = {'rsc_2nd', rsc, 'prsc_2nd', prsc, 'rsig_2nd', rsig, ...
    'prsig_2nd', prsig, 'c0geomn_2nd', geomean([mean([spkrate_c0.mn]), mean([spkrate.mn])])};


% concatenate
rsc_argout = [rsc_all, rsc_2nd];
    
end

%%
function argout = SelectivityCheck(exinfo, ex)
% Anova for selectivity

idx_nonblank = getNoBlankIdx(exinfo, ex);


p_anova = anova1([ex.Trials(idx_nonblank).spkRate], ...
    [ex.Trials(idx_nonblank).(exinfo.param1)],'off');

argout  = {'p_anova', p_anova};

end


%%
function argout = FF(exinfo, ex)
% Fano Factors

% results for all data
[ex, spkrate, spkcount] = znormex(ex, exinfo);

[ ff.classic, ff.fit, ff.mitchel, ff.church ] = ...
    FanoFactors( ex, [spkcount.mn], [spkcount.var], [spkrate.nrep], exinfo.param1);


% results for the second half
ex.Trials = getPartialTrials(ex.Trials);
[ex, spkrate, spkcount] = znormex(ex, exinfo);

[ ff.classic_2ndhalf, ff.fit_2ndhalf, ff.mitchel_2ndhalf, ff.church_2ndhalf ] = ...
    FanoFactors( ex, [spkcount.mn], [spkcount.var], [spkrate.nrep], exinfo.param1);



argout = {'ff', ff};
end

%%
function argout = fitTC(exinfo, spkrate, ex, fname)
% Fitting the tuning curve with established functions

if strcmp(exinfo.param1, 'or')
    fitparam = fitOR( [spkrate.mn], [spkrate.sem], [spkrate.or] );
    
elseif strcmp(exinfo.param1, 'co')
    
    idx_nonblank = getNoBlankIdx(exinfo, ex);
    fitparam = fitCO([spkrate.mn], [spkrate.(exinfo.param1)]);
    
    % check for underspampling
    i_cosmc50 = [ex.Trials.(exinfo.param1)]<=fitparam.c50 & idx_nonblank; % smaller than c50
    fitparam.undersmpl(1) = anova1([ex.Trials(i_cosmc50).spkRate], [ex.Trials(i_cosmc50).(exinfo.param1)],'off');
    
    i_cohic50 = [ex.Trials.(exinfo.param1)]>fitparam.c50 & idx_nonblank;% higher than c50
    fitparam.undersmpl(2) = anova1([ex.Trials(i_cohic50).spkRate], [ex.Trials(i_cohic50).(exinfo.param1)],'off');
    
    % in case of the drug file, test the contrast gain and activity gain model 
    if strfind( fname , exinfo.drugname )
        fitparam.sub = fitCO_drug([spkrate.mn], [spkrate.(exinfo.param1)], exinfo.fitparam);
    end
    
elseif strcmp(exinfo.param1, 'sz')
    fitparam = fitSZ([spkrate.mn], [spkrate.sd], [spkrate.(exinfo.param1)]);
    
elseif strcmp(exinfo.param1, 'sf')
    fitparam_lin = fitSF([spkrate.mn], [spkrate.sd], [spkrate.(exinfo.param1)], false );
    fitparam_log = fitSF([spkrate.mn], [spkrate.sd], [spkrate.(exinfo.param1)], true );
    
    % first entry linear fit, second entry log scaled fit
    fitparam.others = {fitparam_lin; fitparam_log};
else
    fitparam = [];
end

argout = {'fitparam', fitparam};

end

%%
function idx_nonblank = getNoBlankIdx(exinfo, ex)

if strcmp(exinfo.param1, 'co')
    idx_nonblank = [ex.Trials.(exinfo.param1)] ~= ex.exp.e1.blank & ...
        [ex.Trials.(exinfo.param1)] ~= 0;
else
    idx_nonblank = [ex.Trials.(exinfo.param1)] < ex.exp.e1.blank;
end
end