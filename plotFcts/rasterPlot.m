function h = rasterPlot( exinfo, ex, ex_drug)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

h = figure('Name', exinfo.figname, 'UserData', exinfo);

j = exinfo.pfi;
j2 = exinfo.pfi_drug;

if exinfo.isadapt
    time = 0:0.001:5;
else
    time = 0:0.001:0.5;
end

% baseline
subplot(3, 1, 1);
plot(repmat(time', 1, ex.trials_n(j)) , ex.rastercum{j}', 'b.');
title([exinfo.param1 ' ' num2str(ex.raster_pval(j)) ' n=' num2str(ex.trials_n(j)) ]);
ylim([0, ex.trials_n(j)]);
set(gca, 'XTick', []); box off;


% drug condition
subplot(3, 1, 2);
plot(repmat(time', 1, ex_drug.trials_n(j2)), ex_drug.rastercum{j2}', 'r.');
title([' n=' num2str(ex_drug.trials_n(j2)) ]); box off;
ylim([0, ex_drug.trials_n(j2)]);
set(gca, 'XTick', []); box off;

%%% PSTH
subplot(3, 1, 3);
ker = gaussian(0, 1, 1, 0, -5:5) ; ker = ker/sum(ker);
plot(time, conv(sum(ex_drug.raster{j2}, 1), ker, 'same'), 'Color', [1 0 0 0.5]);     hold on;
plot(time, conv(sum(ex.raster{j}, 1), ker, 'same'),  'Color', [0 0 1 0.5]);
set(gca, 'XLim', [0 0.5]); box off;

savefig(h, exinfo.fig_raster);
close(h);


end

