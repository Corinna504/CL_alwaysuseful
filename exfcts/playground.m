%
% @author: Corinna Lorenz

%% analysis


close all; clc

ind1 = [expInfo.is5HT];
ind2 = [expInfo.valid];

n5HT = length(expInfo(ind1&ind2));
nNaCl = length(expInfo(~ind1&ind2));


fprintf('n %1f \n', length([expInfo(ind2)]));
fprintf('n(5HT) %1f \n', length([expInfo(ind1&ind2)]));

fprintf('---------------------------------- \n\n')

%% fano factor
fprintf('Fano Factor Analysis \n\n\n')

% mean
fprintf('mean FF Cluster 1: 5HT (%3.2f) \t baseline (%3.2f) \n\n', ...
    mean([expInfo(ind2 & ind1).ff1]), mean([expInfo(ind2 & ind1).ff1_drug]));
fprintf('mean FF Cluster 1: NaCL (%3.2f) \t baseline (%3.2f) \n\n\n', ...
    mean([expInfo(ind2 & ~ind1).ff1]), mean([expInfo(ind2 & ~ind1).ff1_drug]));

% distribution plot
figure;
subplot(2,1,1)
hist([[expInfo(ind2 & ind1).ff1]',[expInfo(ind2 & ind1).ff1_drug]']); hold on;
title('FF Cluster 1 5HT');      xlim([0, 8]);
subplot(2,1,2)
hist([[expInfo(ind2 & ~ind1).ff1]',[expInfo(ind2 & ~ind1).ff1_drug]']); hold on;
title('FF Cluster 1 NaCl');      xlim([0, 8]); legend('base', 'drug');

% test
fprintf('ff Wilcoxon Test w/ vs. w/o 5HT in Cluster 1: p = %3.2f \n\n', ...
    ranksum([expInfo(ind2 & ind1).ff1],[expInfo(ind2 & ind1).ff1_drug]));
fprintf('ff Wilcoxon Test w/ vs. w/o NaCl in Cluster 1: p = %3.2f \n\n', ...
    ranksum([expInfo(ind2 & ~ind1).ff1],[expInfo(ind2 & ~ind1).ff1_drug]));

fprintf('---------------------------------- \n\n')


%% noise and signal correlation
fprintf('noise and signal correlation \n\n\n');

fprintf('mean r_sc and r_sig for no drug: %3.2f \t %3.2f \n\n', mean([expInfo(ind2).rsc]),...
    mean([expInfo(ind2).rsig]));
fprintf('mean r_{sc} and mean r_{sig} for serotonin: %3.2f \t %3.2f \n\n', ...
    mean([expInfo(ind1&ind2).rsc_drug]) , mean([expInfo(ind1&ind2).rsig_drug]));
fprintf('mean r_{sc} and mean r_{sig} for NaCl: %3.2f \t %3.2f \n\n\n', ...
    mean([expInfo(~ind1&ind2).rsc_drug]), mean([expInfo(~ind1&ind2).rsig_drug]));

fprintf('----------------------- \n');
fprintf('r_sc test for 5HT vs. baseline: p = %3.2f \n\n', ...
    ranksum([expInfo(ind1&ind2).rsc], [expInfo(ind1&ind2).rsc_drug]));
fprintf('r_sc test for NaCl vs. baseline: p = %3.2f \n\n', ...
    ranksum([expInfo(~ind1&ind2).rsc], [expInfo(~ind1&ind2).rsc_drug]));
fprintf('r_sc test for 5HT-baseline vs. NaCl-baseline: p = %3.2f \n\n\n', ...
    ranksum([expInfo(ind1&ind2).rsc]-[expInfo(ind1&ind2).rsc_drug], ...
    [expInfo(~ind1&ind2).rsc]-[expInfo(~ind1&ind2).rsc_drug]));

fprintf('----------------------- \n');
fprintf('r_sig test for 5HT vs. baseline: p = %3.2f \n\n', ...
    ranksum([expInfo(ind1&ind2).rsig], [expInfo(ind1&ind2).rsig_drug]));
fprintf('r_sig test for NaCl vs. baseline: p = %3.2f \n\n', ...
    ranksum([expInfo(~ind1&ind2).rsig], [expInfo(~ind1&ind2).rsig_drug]));
fprintf('r_sig test for 5HT-baseline vs. NaCl-baseline: p = %3.2f \n\n\n', ...
    ranksum([expInfo(ind1&ind2).rsig]-[expInfo(ind1&ind2).rsig_drug], ...
    [expInfo(~ind1&ind2).rsig]-[expInfo(~ind1&ind2).rsig_drug]));


%%% get correlation between r_sc and spikes rspt. r_sig and spikes
disp('partial correlation with mean spike count in cluster 1')
array2table(partialcorr([[[expInfo(ind2).rsc_drug], [expInfo(ind2).rsc]]',...
    [[expInfo(ind2).rsig_drug], [expInfo(ind2).rsig]]', ...
    [[expInfo(ind2).nspk_drugC1], [expInfo(ind2).nspkC1]]']),...
    'VariableNames',{'r_sc','r_sig','spk'},...
    'RowNames',{'r_sc','r_sig','spk'})


disp('partial correlation with mean spike count in cluster 0')
array2table(partialcorr([[[expInfo(ind2).rsc_drug], [expInfo(ind2).rsc]]',...
    [[expInfo(ind2).rsig_drug], [expInfo(ind2).rsig]]', ...
    [[expInfo(ind2).nspk_drugC0], [expInfo(ind2).nspkC0]]']),...
    'VariableNames',{'r_sc','r_sig','spk'},...
    'RowNames',{'r_sc','r_sig','spk'})

fprintf('---------------------------------- \n\n')

%% gain change

fprintf('gain modulation for NaCl and serotonin (median): %3.2f \t %3.2f \n\n', ...
    median([expInfo(~ind1&ind2).gslope]) , median([expInfo(ind1&ind2).gslope]));

fprintf('gain modulation for NaCl and serotonin (mean): %3.2f \t %3.2f \n\n', ...
    mean([expInfo(~ind1&ind2).gslope]) , mean([expInfo(ind1&ind2).gslope]));

fprintf('additive modulation for NaCl and serotonin (median): %3.2f \t %3.2f \n\n', ...
    median([expInfo(~ind1&ind2).yoff]) , median([expInfo(ind1&ind2).yoff]));

fprintf('additive modulation for NaCl and serotonin (mean): %3.2f \t %3.2f \n\n', ...
    mean([expInfo(~ind1&ind2).yoff]) , mean([expInfo(ind1&ind2).yoff]));



fprintf('gain change 5HT vs. Gaussian: p = %3.2f \n\n',...
    ttest([expInfo(ind1&ind2).gslope]));

fprintf('gain change 5HT vs. NaCl : p = %3.2f \n\n',...
    ranksum([expInfo(ind1&ind2).gslope], [expInfo(~ind1&ind2).gslope]));


fprintf('additive change 5HT vs. Gaussian: p = %3.2f \n\n',...
    ttest([expInfo(ind1&ind2).yoff]));

fprintf('additive change 5HT vs. NaCl: p = %3.2f \n\n',...
    ranksum([expInfo(ind1&ind2).yoff], [expInfo(~ind1&ind2).yoff]));


%%% plots
figure
subplot(2,1,1); hist(log([expInfo(ind1&ind2).gslope]), 10); title(['log gslope 5HT (n = ' num2str(n5HT) ')']);
xlim([-1, 1]);
subplot(2,1,2); hist(log([expInfo(~ind1&ind2).gslope]), 3); title(['log gslope NaCl (n = ' num2str(nNaCl) ')']);
xlim([-1, 1]);

figure
subplot(2,1,1); hist([expInfo(ind1&ind2).yoff], 10); title(['additive change 5HT (n = ' num2str(n5HT) ')']);
xlim([-20, 20])
subplot(2,1,2); hist([expInfo(~ind1&ind2).yoff], 3); title(['additive change NaCl (n = ' num2str(nNaCl) ')']);
xlim([-20, 20])

fprintf('---------------------------------- \n\n')


%% other fano factors
fprintf('Mitchel \n\n')






%% 

% r_sc
figure
title('r_sc in drug and baseline condition')
scatter([expInfo(ind1 & ind2).rsc] , [expInfo(ind1 & ind2).rsc_drug], '*'); hold on
scatter([expInfo(~ind1 & ind2).rsc], [expInfo(~ind1 & ind2).rsc_drug], 'fill', 'd')

xlabel('baseline r_{sc}');
ylabel('drug r_{sc}');
legend('5HT', 'NaCl', 'Location', 'SouthEast');


% r_signal
figure
title('r_sig in drug and baseline condition')
scatter([expInfo(ind1 & ind2).rsig] , [expInfo(ind1 & ind2).rsig_drug], '*'); hold on
scatter([expInfo(~ind1).rsig], [expInfo(~ind1).rsig_drug], 'fill', 'd')

xlabel('baseline r_{signal}');
ylabel('drug r_{signal}');
legend('5HT', 'NaCl', 'Location', 'SouthEast');

fprintf('---------------------------------- \n\n')

%% plotting 3D nspk-r_sc-r_sig
figure
plot3([expInfo(ind1&ind2).nspkC1], [expInfo(ind1&ind2).rsc], [expInfo(ind1&ind2).rsig], 'r+'); hold on;
plot3([expInfo(ind1&ind2).nspk_drugC1], [expInfo(ind1&ind2).rsc_drug], [expInfo(ind1&ind2).rsig_drug], 'b*'); hold on;
plot3([expInfo(~ind1&ind2).nspk_drugC1], [expInfo(~ind1&ind2).rsc_drug], [expInfo(~ind1&ind2).rsig_drug], 'ko'); hold on;

grid on
ylim([-1, 1]);
zlim([-1, 1]);


xlabel('mean firing count');
ylabel('r_{sc}');
zlabel('r_{signal}');

legend('baseline', 'serotonin', 'NaCl');

%% plotting fano factor
figure
plot([expInfo(ind1&ind2).ff1], [expInfo(ind1&ind2).nspkC1], 'r+'); hold on;
plot([expInfo(ind1&ind2).ff1_drug], [expInfo(ind1&ind2).nspk_drugC1], 'b*'); hold on;

xlabel('FF1');
ylabel('# spk');

legend('baseline', 'drug');




%% plotting wave form

c = lines(length(expInfo));
tb4 = 55;
l = size(expInfo(1).mnwv, 2);
timeX = 1:l;
timeX = timeX * (1700/l);

figure
for i = 1:length(expInfo)
    
    if isempty(expInfo(i).wdt) 
        plot(0, 0, 'Color', c(i,:)); hold on;
        continue;
    elseif isnan(expInfo(i).wdt) 
        plot(0, 0, 'Color', c(i,:)); hold on;
        continue;
    elseif i==52 || i==54
        wavemn = -expInfo(i).mnwv;
    else
        wavemn = expInfo(i).mnwv;
    end
    
    

    [~, idxmin] = findpeaks(-wavemn, 'MINPEAKHEIGHT', 0.025);
    idxmin = idxmin(1);
    [~, idxmax] = findpeaks(wavemn, 'MINPEAKHEIGHT', 0.025);
    
    idxstart = idxmin -tb4;
        
    dur = timeX(idxstart:end) - timeX(idxstart) - (timeX(idxmin)-timeX(idxstart));
    
    plot(dur, wavemn(idxstart:end), 'Color', c(i,:)); hold on;
%      plot(wavemn, 'Color', c(i,:)); hold on;
    
end



line([0, 0], [-1, 1],  'Color', [0.9 0.9 0.9 ]);
line([200, 200], [-1, 1],  'Color', [0.9 0.9 0.9 ]);

title('waveforms aligned at trough - spline interpolation of mean waveform');
xlabel('time in \mus'); ylabel('normed amplitude (rspt. to trough/peak diff)'); 
legend(cellstr(num2str([1:length(expInfo)]')))
hold off;

% %%
% figure;

axes('Position',[0.65,0.7,0.2,0.2])
hist([expInfo([expInfo.wdt] > 0).wdt], 15);
xlabel('duration in \mus'); ylabel('# of cells');