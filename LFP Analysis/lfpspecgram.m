function [S,t,f] = lfpspecgram(exlfp, movingwin, params)
% plots the average stimulus spectogram

[S,t,f] = spec_helper([], [], exlfp, movingwin, params, 1);

end


function [S,t,f] = spec_helper(~, ~, exlfp, movingwin, params, k)


[ stimparam, vals] = getStimParam( exlfp );

if k > length(vals);     k = 1;     end
    
trials = exlfp.Trials( [exlfp.Trials.(stimparam)] == vals(k));
lfp = vertcat(trials.LFP_interp);
[S,t,f] = mtspecgramc(lfp', movingwin, params );

t = t-0.05;
imagesc( t, f, log(S)', 'ButtonDownFcn', ...
    {@spec_helper, exlfp, movingwin, params, k+1});   

col = lines(length(vals));

title(['stim = ' num2str(vals(k))], 'Color', col(k,:));
xlabel('time [s]');
ylabel('frequency');

set(gca, 'FontSize', 8, 'XTick', [0 0.2 0.4]);

end