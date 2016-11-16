function rasterPlot( exinfo, ex, ex_drug )
% classical raster plot for both conditions with stimulus indicating color 
% and lines indicating trial that were first in the fixation period
% 
% saves the figure in exinfo.fig_raster
% 
% @CL 16.11.2016
% 


% --------------------------------------- plot
h = figure('Name', exinfo.figname, 'UserData', exinfo, ...
    'Position', [680   156   560   822]);
rasterPlotHelper(exinfo, ex, ex_drug)

% --------------------------------------- save
savefig(h, exinfo.fig_raster);
close(h);
end



%%
function rasterPlotHelper(exinfo, ex, ex_drug)
% this is the meta function for the true plotting
% it calls to plot the raster for each condition with plotCondition(..) 
% and the stimulus annotation in the lower part of the figure

if exinfo.isadapt
    time = 0:0.001:5;
else
    time = -0.05:0.001:0.45;
end

% baseline raster
subplot(8,2,1:2:14);
plotCondition(addWindow(exinfo, ex.Trials), time, exinfo.param1, exinfo.ratepar)
title('baseline');

% drug raster
subplot(8,2,2:2:14);
plotCondition(addWindow(exinfo, ex_drug.Trials), time, exinfo.param1, exinfo.ratepar)
title(exinfo.drugname);

% stimulus parameter and corresponding color
subplot(8,2, [15 16]);
l = length(exinfo.ratepar); 
xlim([0, l+1]); 
col = lines(l);
for pos = 1:l
    plot([pos-0.5, pos+0.5], [0 0], 'Color', [col(pos, :) 0.5], 'LineWidth', 3);
    hold on;
    text(pos-0.35, 0, sprintf('%1.2f ', exinfo.ratepar(pos)), 'FontSize', 9);
end
text(0.5, 0.5, [exinfo.param1 ', grey=1st trial'], 'FontSize', 9);
axis off;
end



function plotCondition(Trials, time, param, parvls)
%%% plot the raster matrix according to different stimuli
% also indicate phase and window 

row_i = 1;
col = lines(length(parvls));

% all the trials 
for par_i = 1:length(parvls)
    trials = Trials( [Trials.(param)] == parvls(par_i));
    
    row_i = getRasterPlotMatrix(trials, time, row_i, col(par_i, :));
    row_i = row_i+0.3;
end

xlim([-0.05 0.45]); ylim([1, row_i-0.3]);
plot([0 0], [1, row_i-0.3], 'Color', [0.5 0.5 0.5]);

set(gca, 'Clipping', 'off', 'TickDir', 'out'); box off;
end


function [y_idx, raster] = getRasterPlotMatrix(Trials, time, y_idx, col)
% converts the time stemps of spikes into a sequence of 0s and 1s, with 1s
% indicating a spike event. Each row is one trial.

% initiate raster
raster = nan(length(time), length(Trials));



% each row is a trial, each column a time bin
for t = 1:length(Trials)
    
    t_strt = Trials(t).Start - Trials(t).TrialStart;
    
    if time(end)>0.5
        t_strt = t_strt(t_strt<=5);
    end
    
    % spikes in the time range
    spk =  Trials(t).Spikes(...
        Trials(t).Spikes>=t_strt(1)+min(time) &  Trials(t).Spikes<=t_strt(end));
    spk = spk-t_strt(1); % align spikes to stimulus onset
    
    % adding each spike event as '1' to the raster matrix
    idx = round(( spk + abs(time(1)) ) *1000);
    idx(idx==0) = 1; % avoid an index of 0
    raster(idx, t) = 1;
    
    % plotting
    if Trials(t).window == 1
        fill([time(1), time(end), time(end), time(1)],...
            [y_idx, y_idx, y_idx+0.95, y_idx+0.95], ...
            [0.5 0.5 0.5], 'FaceAlpha', 0.2, 'EdgeAlpha', 0); hold on;
    end
    plot([spk spk]', repmat([y_idx; y_idx+1], 1, length(idx)), ...
        'Color', col);
    plot([time(end); time(end)], [y_idx; y_idx+0.95], 'Color', col);
    
    y_idx = y_idx+1;
    hold on;

end

end