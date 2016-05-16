function [ dat ] = fctMitchel( expInfo )
%fctMitchel
% Trials without reward are excluded. Each neuron in each condition is one
% date point.



%%% x
dat.xtick = [0.1 0.1778 0.31 0.5623 1 1.7783 3.10 5.6234 10 20]; % adopt from Mitchel et al. Fig 3
dat.x = dat.xtick(1:9) + diff(dat.xtick)/2 ; 
axis_i = [1:2:9, 10];

%%% y
temp_mn  = [];   temp_mndrug  = [];
temp_sem = [];   temp_semdrug = [];

for i = 1:length(expInfo)
    
    temp_mn      = [temp_mn, expInfo(i).mitchel_mn];
    temp_mndrug  = [temp_mndrug, expInfo(i).mitchel_mn_drug];
    temp_sem     = [temp_sem, expInfo(i).mitchel_sem];
    temp_semdrug = [temp_semdrug, expInfo(i).mitchel_sem_drug];
    
end

dat.leg = {'base', 'drug'};

dat.errbar        = [nanmean(temp_mn, 2) , nanmean(temp_sem,2)];
dat.errbar_drug   = [nanmean(temp_mndrug, 2) , nanmean(temp_semdrug,2)];

errorbar(dat.x, dat.errbar (:,1), ...
    dat.errbar(:,2),...
    'Color', 'r'); hold on;
errorbar(dat.x, dat.errbar_drug (:,1), ...
    dat.errbar_drug(:,2),...
    'Color', 'b'); 
%%% axes specifications
legend(dat.leg);
set(gca, 'XTick', dat.xtick(axis_i),...
    'XTickLabel', cellfun(@num2str, num2cell(dat.xtick(axis_i)), 'UniformOutput', 0),...
    'XScale', 'log', 'YScale', 'log');
xlim([0,20]);

%%% bins
for binEdge = dat.xtick(2:end)
    line([binEdge binEdge], [0.11 30], 'Color', [0.9,0.9,0.9]); hold on;
end

%%% unity line
line([0.1 35], [0.1 35], 'Color', [.3, .3, .3]);



dat.info = 'dat.errbar, dat.errbar_drug';


hold off;
end

