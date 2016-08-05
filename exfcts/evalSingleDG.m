function [ex, argout] = evalSingleDG( exinfo, fname )
% batch file that calls all functions to evaluated drifiting grating trials


rate_flag = true;
ex = loadCluster( fname ); % load raw data
ex.Trials = ex.Trials([ex.Trials.me] == exinfo.ocul);


% %% LFP - now moved to its own gui
lfp_avg = []; pow_avg = [];



%% Spiking 
%%% z normed spike rates entered in ex.Trials
[ex, spkstats, phaseResp, f1] = znormex(ex, exinfo, rate_flag);

%%% Fano Factors
[ ff.classic, ff.fit, ff.mitchel, ff.church ] = ...
    FanoFactors( ex, [spkstats.mn], [spkstats.var], exinfo.param1);

%%% Cluster Analysis
fnamec0 = strrep(fname, exinfo.cluster, 'c0'); % load cluster 0
exc0 = loadCluster( fnamec0 );
exc0.Trials = exc0.Trials([exc0.Trials.me] == exinfo.ocul);

%%% Noise Correlation
[exc0, spkstatsc0] = znormex(exc0, exinfo, rate_flag); % z norm
[rsc, prsc] = corr([ex.Trials.zspkrate]', [exc0.Trials.zspkrate]', 'rows', 'complete');

%%% Signale Correlation
[rsig, prsig] = corr([spkstats.mn]', [spkstatsc0.mn]', 'rows', 'complete');



%% Fitting
if strcmp(exinfo.param1, 'or')
    fitparam = fitgaussOR(spkstats);
elseif strcmp(exinfo.param1, 'co')
    if strfind( fname , exinfo.drugname )
        fitparam = fitCO_drug([spkstats.mn], [spkstats.(exinfo.param1)], exinfo.fitparam);
    else
        fitparam = fitCO([spkstats.mn], [spkstats.(exinfo.param1)]);
    end
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


%% Phase dependence
spkwoblank = [spkstats( [spkstats.(exinfo.param1)] < 1000).mn];
phasesel(1) = nanmean(f1(:,1)./spkwoblank');

% [~, max_i] = max(spkwoblank);
phasesel(2) = nanmean(f1(:,2));


%% assign output arguments
argout =  {'fitparam', fitparam, ...
    'rateMN', [spkstats.mn]', 'rateVARS', [spkstats.var]', ...
    'ratePAR', [spkstats.(exinfo.param1)]', 'rateSME', [spkstats.sd]', ...
    'rsc', rsc, 'prsc', prsc, ...
    'rsig', rsig, 'prsig', prsig, ...
    'ff', ff, 'tcdiff', tcdiff, ...
    'powst_mn', pow_avg, 'lfpst_mn', lfp_avg, ...
    'ed', ed, 'eX', eX, 'eY', eY, 'phasesel', phasesel, 'phaseRespM', phaseResp};
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


function [ex, spkstats, phaseResp, f1] = znormex(ex, exinfo, norm_flag)
%znormex
% converts spike rates to z-normed data for each condition pair
% norm_flag determines if to use spike rate (norm_falg = 1) or spike count
% (norm_flag = 0)


param1 = exinfo.param1;
parvls = unique( [ ex.Trials.(param1) ] );

phaseResp = zeros(sum(parvls<1000), 4);
phaseN = phaseResp;
f1 = zeros(sum(parvls<1000), 2);
j = 1;

if exinfo.isadapt
    time = 0:0.001:5;
else 
    time = 0.001:0.001:0.45;
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
        
        
        % skip phase analysis if it is a blank
        if par>1000 
            continue
        end
        
        
        % assign spikes to phase and stimulus condition in a matrix later
        % used to plot a heat map of spike acitivity showing the phase
        % sensitivity
        phase_inc = 1/ (4*ex.stim.vals.tf);
        phase_t = t_strt(1);
        phase_i = ct(k).phase;
        
        while phase_t+phase_inc < t_strt(end)-t_strt(1)
            
            
            phaseResp(j, phase_i) = phaseResp(j, phase_i) + ...
                sum( ct(k).Spikes >= phase_t & ...
                ct(k).Spikes <= phase_t + phase_inc);
            
            phaseN(j, phase_i) = phaseN(j, phase_i)+ 1;
            phase_i = phase_i + 1;
            if phase_i > 4
                phase_i = 1;
            end
            phase_t = phase_t + phase_inc;
            
        end
        
        % binned 10ms trial data
        for bin = 0:44
            temp(bin+1) = sum(ex.raster{j}(k,bin*10+1 :bin*10+10, 1)) /0.01;
        end
        [trial_f1(k), trial_freq, trial_pow(:,k)]  = ...
            trialSpec(temp, ex.stim.vals.tf);
    end
    
    
    if par<1000 
        f1(j, 1) = nanmean(trial_f1);
        try
            f1(j, 2) = nanmean(trial_f1./[ex.Trials(ind).spkRate]);
        catch
            disp('');
        end
    end
    
    j = j+1;
    clearvars trial_f1 trial_freq trial_pow;
end


phaseResp = phaseResp./phaseN;
phaseResp = phaseResp./phase_inc;
ex.raster_pval = parvls;

end




function [f1, f_new, P1_new] = trialSpec(temp, tf)
% GET THE CORRECT POWER AT THE TEMPORAL FREQUENCY OF THE
% STIMULUS

%     fouriercoeff = fft(conv(sum(ex.raster{j}, 1), ones(1, 10)/10, 'same'));
%     L = length(ex.raster{j}(1,:));
%     Fs = L / time(end);

fouriercoeff = fft(temp);
L = 45;
Fs = L / 0.45;

try
    P2 = abs(fouriercoeff/L);
    if mod(L,2)==1
        L=L-1;
    end
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
catch
    disp();
end
f = Fs*(0:(L/2))/L;

% interpolate in smaller increments and get the nearest frequency
% to the stimulus tf
f_new = f(1):0.5:f(end);
P1_new = interp1(f, P1, f_new, 'spline');

tf_i = find(f_new>=tf, 1, 'first');
f1 = P1_new(tf_i);


end
