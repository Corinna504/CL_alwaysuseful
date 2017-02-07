function LFP_fullcontrast(dat)
% extract average lfp signal for responses to 100% contrast stimuli

if nargin>0
    parfor i = 1:length(dat)
        dat(i) = setLFP(dat(i));
    end
    save('codat.mat', 'dat');
else
    load('codat');
end

dat = dat([dat.is5HT]);
figure;
evaluateLFP(dat);

end

%%
function dat = setLFP(dat)

[lfpbase, lfpdrug] = LoadLFPfile( dat );
vals = [1001 0.125 0.25 0.5 1];
for vals_i = 1:length(vals)
    
    idx = [lfpbase.Trials.co] == vals(vals_i);
    lfp(vals_i, :) = mean(vertcat(lfpbase.Trials(idx).LFP_interp));
    pow(vals_i, :) = mean(horzcat(lfpbase.Trials(idx).POW), 2);
    
    idx = [lfpdrug.Trials.co] == vals(vals_i);
    lfp_drug(vals_i, :) = mean(vertcat(lfpdrug.Trials(idx).LFP_interp));
    pow_drug(vals_i, :) = mean(horzcat(lfpdrug.Trials(idx).POW), 2);
    
    lfp_diff(vals_i, :) = lfp(vals_i, :)-lfp_drug(vals_i, :);
    pow_diff(vals_i, :) = pow(vals_i, :)-pow_drug(vals_i, :);
end

dat.lfp = lfp;
dat.lfp_drug = lfp_drug;
dat.lfp_diff = lfp_diff;
dat.lfp_ts = lfpbase.time;



dat.pow = pow;
dat.pow_drug = pow_drug;
dat.pow_diff = pow_diff;
dat.freq = lfpdrug.Trials(1).FREQ;

end


%%
function evaluateLFP(dat)
%% evaluate LFP by plotting mean and standard error

t = dat(1).lfp_ts; % time vector
t2 = [t fliplr(t)]; % for sem patch
n = length(dat);

vals = [1001 0.125 0.25 0.5 1];

col_base = repmat([0.8 0.6 0.4 0.2 0]', 1,3);
col_5ht = col_base;
col_5ht(:,1) = 1;

%%%% LFP vs time
subplot(2,2,1)
for v_i = 1:length(vals)
    
    fun = @(x) x(v_i,:);
    A(v_i,:) = cellfun(fun, {dat.lfp}, 'UniformOutput', 0);
    B(v_i,:) = cellfun(fun, {dat.lfp_drug}, 'UniformOutput', 0);
    
    %%% Average signal
    lfp_base_avg = mean(vertcat(A{v_i,:}));    % baseline
    lfp_drug_avg = mean(vertcat(B{v_i,:})); % 5HT
    
    %%% plot results
    % Baseline
    plot(t, lfp_base_avg, 'Color', col_base(v_i, :), 'LineWidth', 2, ...
        'DisplayName', ['co=' num2str(vals(v_i)) ' base']); hold on;
    % 5HT
    plot(t, lfp_drug_avg, 'Color', col_5ht(v_i, :), 'LineWidth', 2,...
        'DisplayName', ['co=' num2str(vals(v_i)) ' 5HT']); hold on;
end

legend('show', 'Location', 'bestoutside')

%%% plot deviation (SEM)
for v_i = 1:length(vals)
    % baseline
    lfp_base_avg = mean(vertcat(A{v_i,:}));
    lfp_base_sem = std(vertcat(A{v_i,:}))/ sqrt(n);
    fill(t2, [lfp_base_avg+lfp_base_sem, fliplr(lfp_base_avg-lfp_base_sem)], ...
        col_base(v_i,:), 'EdgeColor', 'none', 'FaceAlpha', 0.5,...
        'DisplayName', ' ');
    
    % 5HT
    lfp_drug_avg = mean(vertcat(B{v_i,:}));
    lfp_drug_sem = std(vertcat(B{v_i,:})) / sqrt(n);
    fill(t2, [lfp_drug_avg+lfp_drug_sem, fliplr(lfp_drug_avg-lfp_drug_sem)],....
        col_5ht(v_i,:),'EdgeColor', 'none','FaceAlpha', 0.5,...
        'DisplayName', ' ');
end

xlim([-0.15 0.5]);

ylabel('filtered LFP (V?)');
xlabel('time relative to stimulus onset (ms)');
title('5HT induced changes in the LFP signal');
crossl




%%%% LFP power
f = dat(1).freq';
f2 = [f fliplr(f)]; % for sem patch

subplot(2,2,3)
for v_i = 1:length(vals)
    
    fun = @(x) x(v_i,:);
    A(v_i,:) = cellfun(fun, {dat.pow}, 'UniformOutput', 0);
    B(v_i,:) = cellfun(fun, {dat.pow_drug}, 'UniformOutput', 0);
    
    %%% Average signal
    pow_base_avg = mean(vertcat(A{v_i,:}));    % baseline
    pow_drug_avg = mean(vertcat(B{v_i,:})); % 5HT
    
    %%% plot results
    % Baseline
    plot(f, pow_base_avg, 'Color', col_base(v_i, :), 'LineWidth', 2, ...
        'DisplayName', ['co=' num2str(vals(v_i)) ' base']); hold on;
    % 5HT
    plot(f, pow_drug_avg, 'Color', col_5ht(v_i, :), 'LineWidth', 2,...
        'DisplayName', ['co=' num2str(vals(v_i)) ' 5HT']); hold on;
end

legend('show', 'Location', 'bestoutside')

% %%% plot deviation (SEM)
% for v_i = 1:length(vals)
%     % baseline
%     pow_base_avg = mean(vertcat(A{v_i,:}));
%     pow_base_sem = std(vertcat(A{v_i,:}))/ sqrt(n);
%     fill(f2, [pow_base_avg+pow_base_sem, fliplr(pow_base_avg-pow_base_sem)], ...
%         col_base(v_i,:), 'EdgeColor', 'none', 'FaceAlpha', 0.5,...
%         'DisplayName', ' ');
%     
%     % 5HT
%     pow_drug_avg = mean(vertcat(B{v_i,:}));
%     pow_drug_sem = std(vertcat(B{v_i,:})) / sqrt(n);
%     fill(f2, [pow_drug_avg+pow_drug_sem, fliplr(pow_drug_avg-pow_drug_sem)],....
%         col_5ht(v_i,:),'EdgeColor', 'none','FaceAlpha', 0.5,...
%         'DisplayName', ' ');
% end


ylabel('Power (V^2?)');
xlabel('Frequency (Hz)');
xlim([0 90]); 
set(gca, 'YScale', 'log')




%%% difference in power
subplot(2,2,4)

for v_i = 1:length(vals)
    
    fun = @(x) x(v_i,:);
    A(v_i,:) = cellfun(fun, {dat.pow}, 'UniformOutput', 0);
    B(v_i,:) = cellfun(fun, {dat.pow_drug}, 'UniformOutput', 0);
    
    %%% Average signal
    pow_base_avg = mean(vertcat(A{v_i,:}));    % baseline
    pow_drug_avg = mean(vertcat(B{v_i,:})); % 5HT
    
    %%% plot results
    % Baseline
    plot(f, pow_base_avg-pow_drug_avg, 'Color', col_base(v_i, :), 'LineWidth', 2, ...
        'DisplayName', ['co=' num2str(vals(v_i)) ' base']); hold on;
end

ylabel('Delta Power (V^2?) (base-5HT)');
xlabel('Frequency (Hz)');
xlim([10 90]); 

end



