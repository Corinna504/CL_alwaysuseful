function h = rasterPlot4stimuli( exinfo, ex, ex_drug)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

h = figure('Name', exinfo.figname, 'UserData', exinfo, ...
    'Position', [680   156   560   822]);


if exinfo.isadapt
    time = 0:0.001:5;
else
    time = -0.05:0.001:0.45;
end


% baseline raster
subplot(8,2,1:2:14);
rasterPlotHelper(addWindow(exinfo, ex.Trials), ...
    time, exinfo, exinfo.ratepar)
title('baseline');


% drug raster
subplot(8,2,2:2:14);
rasterPlotHelper(addWindow(exinfo, ex_drug.Trials), ...
    time, exinfo, exinfo.ratepar)
title(exinfo.drugname);


% parameter specification
subplot(8,2, [15 16]);
l = length(exinfo.ratepar);
xlim([0, l+1]);
col = lines(l);
for pos = 1:l
    plot([pos-0.5, pos+0.5], [0 0], 'Color', [col(pos, :) 0.5], 'LineWidth', 3);
    hold on;
    text(pos-0.35, 0, sprintf('%1.2f ', exinfo.ratepar(pos)), ...
        'FontSize', 9);
end
text(0.5, 0.5, sprintf( [exinfo.param1 ', tf= %1.1f, grey=window 1'], exinfo.tf), ...
    'FontSize', 9);
axis off;



savefig(h, exinfo.fig_raster);
close(h);


end




function rasterPlotHelper(Trials, time, exinfo, parvls)
%%% plot the raster matrix according to different stimuli
% also indcate phase and window 

row_i = 1;
col = lines(length(parvls));
   

for par_i = 1:length(parvls)
    trials = Trials( [Trials.(exinfo.param1)] == parvls(par_i));
    
    row_i = getRasterPlotMatrix(trials, time, row_i, col(par_i, :));
    row_i = row_i+0.3;
    
end




xlim([-0.05 0.45]);
ylim([1, row_i-0.3]);
plot([0 0], [1, row_i-0.3], 'Color', [0.5 0.5 0.5]);
box off;
set(gca, 'Clipping', 'off', 'TickDir', 'out')


end


function [y_idx, raster] = getRasterPlotMatrix(Trials, time, y_idx, col)

raster = nan(length(time), length(Trials));

%%% compute a raster matrix
% each row is a trial, each column a time bin
for t = 1:length(Trials)
    
    t_strt = Trials(t).Start - Trials(t).TrialStart;
    
    if time(end)>0.5
        t_strt = t_strt(t_strt<=5);
    end
    
    % spikes in the time range
    spk =  Trials(t).Spikes(...
        Trials(t).Spikes>=t_strt(1)+min(time) & ...
        Trials(t).Spikes<=t_strt(end))-t_strt(1)  ;
    
    % adding it to the raster matrix
    idx = round(( spk + abs(time(1)) ) *1000);
    idx(idx==0) = 1; % avoid bad indexing
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