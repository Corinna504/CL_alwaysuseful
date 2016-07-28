function pow_avg = lfpFreqDomain(exlfp, frange)
% stimulus triggered average

[ stimparam, vals] = getStimParam( exlfp );
col = lines(length(vals));

%%% frequency domain offset

fidx = exlfp.Trials(1).FREQ>= frange(1) & exlfp.Trials(1).FREQ <= frange(2);
f = exlfp.Trials(1).FREQ(fidx);

%%%
pow_sing = nanmean(horzcat(exlfp.Trials.POW),2);

%%%
for i = 1:length(vals)
    
    trials = exlfp.Trials([exlfp.Trials.(stimparam)] == vals(i));
    pow_avg(i,:) = nanmean(horzcat(trials.POW),2);
    
    plot(f, pow_avg(i,fidx), 'Color', col(i, :), ...
        'ButtonDownFcn', ...
        {@PlotSingleTrials, f, fidx, trials, vals(i), col(i,:)}); hold on
    
end
% legend(num2str(vals'));
xlim([f(1) f(end)]);
xlabel('Frequency'); ylabel('avg Power');
set(gca, 'YScale', 'log');

pow_avg = pow_avg(:,fidx);
end


function PlotSingleTrials(~, ~,f, fidx, trials, stim, col)
% Callback function for single averaged signals to show the individual
% trials

figure('Name', ['All Frequency Domain Trials Stim=' num2str(stim)]);
off = 0;
for i= 1:length(trials)
    
    plot(f, trials(i).POW(fidx)+off, 'Color', col); hold on;
    
    off = off + max(trials(i).POW(fidx))*2;
end

title(['trial for stimulus = ' num2str(stim)])
xlabel('Frequency');
ylabel('stacked LFP');

end



