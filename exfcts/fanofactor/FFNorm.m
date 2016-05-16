
function [mitchel_info, chruchland_info] = FFNorm(expInfo)
% 9/29/2015
% @ Corinna Lorenz


chruchland_info = Churchlandetal(expInfo);




times = 100:50:660; % from 100 ms before target onset until 450 ms after.
fanoParams.alignTime = 200; % this time will become zero time
fanoParams.boxWidth = 50; % 50 ms sliding window.

Result_base5HT = VarVsMean(chruchland_info.base5HT, times, fanoParams);
% plotFano(Result_base5HT);

Result_serotonin = VarVsMean(chruchland_info.serotonin, times, fanoParams);
% plotFano(Result_serotonin);

Result_baseNaCl = VarVsMean(chruchland_info.baseNaCl, times, fanoParams);
% plotFano(Result_baseNaCl);

Result_NaCl = VarVsMean(chruchland_info.NaCl, times, fanoParams);
% plotFano(Result_NaCl);


figure
subplot(2,1,1);
plot(Result_serotonin.times, Result_serotonin.meanRateSelect, 'k'); hold on;
plot(Result_base5HT.times, Result_base5HT.meanRateSelect, 'Color', [.7 .7 .7]); hold on;
ylabel('rate (spk/s)');

subplot(2,1,2);
plot(Result_serotonin.times, Result_serotonin.FanoFactor, 'k'); hold on;
plot(Result_base5HT.times, Result_base5HT.FanoFactor, 'Color', [.7 .7 .7]); hold on;

xlabel('Time in ms (0=time of stimulus onset)');
ylabel('Fano Factor');
legend('5HT', 'control');
title('FF Analysis with all data');

% FF is smaller when regression is used instead of geomatrical mean fit

% TODO: Fit FF-slope for each neuron
end