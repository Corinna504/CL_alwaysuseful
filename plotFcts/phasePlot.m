function phasePlot( exinfo )
% plots the two heat maps of stimuliXphase against each other

h = figure('Name', exinfo.figname, 'UserData', exinfo);

colormap(jet);

%%% Baseline
stimwoblank = exinfo.ratepar( exinfo.ratepar < 1000 );

subplot(2,1,1);
imagesc('XData',1:4,'YData',1:length(stimwoblank),'CData', exinfo.phaseRespM);

title(sprintf(['baseline f1/f0 all (' exinfo.param1 ' = %1.1f) =%1.2f (%1.2f)'], ...
    exinfo.ratepar(exinfo.pfi), exinfo.phasesel));
set(gca, 'YTick', 1:length(stimwoblank), 'YTickLabel', cellstr(num2str(stimwoblank')), 'XTick', []);

ylabel(exinfo.param1);
ylim([0.5 length(stimwoblank)+0.5])
xlim([0.5 4.5]);
colorbar


%%% Drug
stimwoblank = exinfo.ratepar_drug( exinfo.ratepar_drug < 1000 );

subplot(2,1,2);
imagesc('XData',1:4,'YData', 1:length(stimwoblank),'CData', exinfo.phaseRespM_drug);

title(sprintf([exinfo.drugname ' f1/f0 all (' exinfo.param1 ' = %1.1f) =%1.2f (%1.2f)'], ...
    exinfo.ratepar_drug(exinfo.pfi_drug), exinfo.phasesel_drug));

xlabel('phase'); ylabel(exinfo.param1);
set(gca, 'YTick', 1:length(stimwoblank),  'YTickLabel', cellstr(num2str(stimwoblank')), ...
    'Xtick', 1:4);
ylim([0.5 length(stimwoblank)+0.5])
xlim([0.5 4.5]);
colorbar


savefig(h, exinfo.fig_phase);

close(h);

end

