function [S,t,f] = lfpspecgram(exlfp, movingwin, params, k)
% plots the average stimulus spectogram
% in order to compare the stimulus induced changes, we 

[stimparam, vals] = getStimParam( exlfp );

% stimulus
trials = exlfp.Trials( [exlfp.Trials.(stimparam)] == vals(k));
[S, t, f] = computeSpectogram(trials , movingwin, params);

% if any(vals>1000) && vals(k) < 1000 
%     % blank
%     trials = exlfp.Trials( [exlfp.Trials.(stimparam)] == vals(vals>1000));
%     S_blank = computeSpectogram(trials , movingwin, params);
%     % normalize to a 'baseline' LFP
%     S = S-S_blank;
%     S(S<0)=0;
%     spec_helper([], [], exlfp, S, t, f, k);
% end

    spec_helper([], [], exlfp, S, t, f, k);


end


function [S,t, f] = computeSpectogram(trials, movingwin, params)
% compute the specogram given all the repeatadly recorded LFP

lfp = vertcat(trials.LFP_interp);
lfp = lfp (mean(isnan(lfp), 2)==0,:);
params.err = 0;
[S,t,f] = mtspecgramc(lfp', movingwin, params );

t = t-0.2;
% prestim_pow = repmat(mean(S(t<0, :)), length(t), 1);
% S = S ./ prestim_pow;
end


function [] = spec_helper(~, ~, exlfp, S, t, f, k)
% plot the spectogram and name labels and plot

plot_matrix(S, t, f);   

[~, vals] = getStimParam( exlfp );
col = lines(length(vals));

title(['stim = ' num2str(vals(k))], 'Color', col(k,:));
xlabel('time [s]');
ylabel('frequency');

set(gca, 'FontSize', 8, 'XTick', [-0.2 0 0.2 0.4], 'YTick', floor(f));

end