function h = lfpPlot( exinfo )
% TODO: COMMENT
% so far only for preferred orientation

h = figure('Name', exinfo.figname, 'UserData', exinfo);

j = exinfo.pfi;
j2 = exinfo.pfi_drug;

powstB_mn = exinfo.powstim_mn(j, :);
powstB_sd = exinfo.powstim_sd(j, :);

powstD_mn = exinfo.powstim_mn_drug(j2, :);
powstD_sd = exinfo.powstim_sd_drug(j2, :);


%%
time = 0:0.001:0.500;
     
%%% LFP power divided into three plots

% ALPHA
s2 = subplot(3, 1, 1);
plot(powstB_mn, 'LineWidth', 2, 'Color', [0 0 1 0.5]); hold on;
plot(powstB_mn+powstB_sd, 'LineStyle', ':', 'Color', [0 0 1 0.5]);
plot(powstB_mn-powstB_sd, 'LineStyle', ':', 'Color', [0 0 1 0.5]);

plot(powstD_mn, 'LineWidth', 2, 'Color', [1 0 0 0.5]);
plot(powstD_mn+powstD_sd, 'LineStyle', ':', 'Color', [1 0 0 0.5]);
plot(powstD_mn-powstD_sd, 'LineStyle', ':', 'Color', [1 0 0 0.5]);

ind = 8:10;
ymax = max( [powstB_mn(ind)+ powstB_sd(ind) , powstD_mn(ind)+ powstD_sd(ind)]);
ymin = min( [powstB_mn(ind)- powstB_sd(ind) , powstD_mn(ind)- powstD_sd(ind)]);
ylim( [ymin ymax] ); xlim([8 13]); box off;
title('Alpha');

% BETA
s3 = subplot(3, 1, 2);
copyobj(get(s2, 'Children'), s3);
ind = 10:30;
ymax = max( [powstB_mn(ind)+ powstB_sd(ind) , powstD_mn(ind)+ powstD_sd(ind)]);
ymin = min( [powstB_mn(ind)- powstB_sd(ind) , powstD_mn(ind)- powstD_sd(ind)]);
ylim( [ymin ymax] ); xlim([10 30]); box off;
title('Beta');

% GAMMA
s4 = subplot(3, 1, 3);
copyobj(get(s2, 'Children'), s4);
ind = 30:80;
ymax = max( [powstB_mn(ind)+ powstB_sd(ind) , powstD_mn(ind)+ powstD_sd(ind)]);
ymin = min( [powstB_mn(ind)- powstB_sd(ind) , powstD_mn(ind)- powstD_sd(ind)]);
ylim( [ymin ymax] );    xlim([30 80]); box off;
title('Gamma');

xlabel('Frequency');
ylabel('Power');


savefig(h, exinfo.fig_lfpPow);
close(h)

end
        


