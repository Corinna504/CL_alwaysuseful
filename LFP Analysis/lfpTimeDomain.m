function lfp_avg = lfpTimeDomain(exlfp)
% stimulus triggered average

[ stimparam, vals] = getStimParam( exlfp );
col = lines(length(vals));

time = -0.05:1/1000:0.45;
%%%
for i = 1:length(vals)
    
    trials = exlfp.Trials([exlfp.Trials.(stimparam)] == vals(i));

    %%% averaged trials
    lfp_avg(i,:) = nanmean(vertcat(trials.LFP_interp), 1);
        
    plot(time, lfp_avg(i,:), 'Color', col(i, :),...
        'ButtonDownFcn',  ...
        {@PlotSingleTrials, trials, vals(i), col(i,:)}); hold on
end

% legend(num2str(vals'), 'Location', 'SouthEast');
set(gca, 'XLim', [time(1) time(end)]);
xlabel('time [s]'); ylabel('avg LFP');
crossl;
end




function PlotSingleTrials(~, ~,trials, stim, col)
% Callback function for single averaged signals to show the individual
% trials

figure('Name', ['All Time Domain Trials Stim=' num2str(stim)]);
off = 0;

for i= 1:length(trials)
    plot([-0.05 0.45], [off, off], 'k:'); hold on;
    
    % raw signal    
    t_strt = trials(i).Start - trials(i).TrialStart;
    t_end = t_strt(end) + mean(diff(t_strt));
    i_raw = trials(i).LFP_ts >= (t_strt(1)-0.05) & trials(i).LFP_ts <= t_end;
    plot(trials(i).LFP_ts(i_raw)-t_strt(1), trials(i).LFP(i_raw)+off,...
       'LineWidth', 2, 'Color', [0.8 0.8 0.8]); hold on;
    
    % filtered signal
    plot(trials(i).LFP_interp_time, trials(i).LFP_interp+off, 'Color', col); hold on;
    off = off + max(trials(i).LFP_interp)*2;
end
    
plot([0 0], get(gca, 'YLim'), 'k--');
title(['trial for stimulus = ' num2str(stim)])
xlabel('time');
ylabel('stacked LFP');
xlim([-0.05 0.45]);
    
end



