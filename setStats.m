function stats = setStats( h, inclusioncrit)
% adds a string to the figure handle h's UserData with all statistical tests and their
% results for the attached data set. The % string can be called via h.UserData.Stats
% 
% It contains the two-sample results (5HT vs. NaCl) and the paired test
% results for each condition (Baselin vs 5HT, Baseline vs NaCl) for both
% and each individual monkey.
%

dat = h.UserData;
idx = [dat.expInfo.is5HT];

%%% all
s = getStatsHelper(dat.x, dat.y, idx);

%%% mango
idx2 =[dat.expInfo.ismango];
s_ma = getStatsHelper(dat.x(idx2), dat.y(idx2), idx(idx2));

%%% kaki
idx2 =~[dat.expInfo.ismango];
s_ka = getStatsHelper(dat.x(idx2), dat.y(idx2), idx(idx2));



% concatenate and save in UserData
dat.Stats = sprintf(['X = ' dat.xlab ' \nY = ' dat.ylab '\n\n' inclusioncrit '\n\nALL' s...
    '\n----------\n\n' 'MANGO' s_ma ...
    '\n----------\n\n' 'KAKI' s_ka]);
set(h, 'UserData', dat);
stats = dat.Stats;

end


function s = getStatsHelper(X, Y, idx)
% calls the statistics for a particular data set
s_5HT = getStatsPairedSample(X(idx), Y(idx));
s_5HT_corr = getCorr(X(idx)', Y(idx)');
s_NaCl = getStatsPairedSample(X(~idx), Y(~idx));
s_NaCl_corr = getCorr(X(~idx)', Y(~idx)');

s_x = getStatsTwoSample(X(idx), X(~idx));
s_y = getStatsTwoSample(Y(idx), Y(~idx));


s = ['\n----5HT\n' s_5HT s_5HT_corr...
    '\n----NaCl\n' s_NaCl s_NaCl_corr...
    '\n----5HT vs. NaCl\n x: ' s_x  ' y: ' s_y];
end


function s = getCorr(x, y)

[rho_p, p_p] = corr(x, y, 'type', 'Pearson');
[rho_sp, p_sp] = corr(x, y, 'type', 'Spearman');


s = sprintf('correlation Pearson: rho=%1.2f  p=%1.7f, \t Spearman: rho=%1.2f  p=%1.7f \n', ...
    rho_p, p_p, rho_sp, p_sp);

end


function s = getStatsTwoSample(sero, nat)
% two sample comparison
[~, ptt] = ttest2(sero, nat);
pwil = ranksum(sero, nat);

s = sprintf('2-sample ttest p=%1.5f, \t wilcoxon p=%1.4f \n', ptt, pwil);
end


function s = getStatsPairedSample(X, Y)
% paired comparison
s_base  = getDistParam(X);
s_drug = getDistParam(Y);

% check for normal distribution
h = kstest(X-Y);
[~, ptt] = ttest(X, Y)
psr = signrank(X, Y)


s = sprintf(['X' s_base 'Y' s_drug ...
    'normal dist X-Y h=%1.0f, paired t-test p=%1.5f, \t paired signrank p=%1.5f \n\n' ], ...
    h, ptt, psr);

end



function s = getDistParam(A)

n = length(A);

% distribution values
prct =  prctile(A, [2.5 50 97.5]);

mn_ = nanmean(A);
std_ = nanstd(A);

if any(A<0)
    geomn_ = -inf;
else
    geomn_ = geomean(A);
end

% check for normal distribution
[~,psphericity] = kstest(A);

% test for significant difference to normal distribution 
[~, pttest] = ttest(A, 0);   
psignr = signrank(A);


s = sprintf(['(N = %1.0f) \n' ...
    'percentile (2.5, 50, 97.5): %1.2f/%1.2f/%1.2f, \t mean: %1.2f +- %1.2f SD, \t GM: %1.2f \n' ...
    'test for normal dist p=%1.5f, \t t-test vs. 0 p = %1.5f, \t signrank test vs 0 p: %1.5f \n\n'], ...
    n, prct, mn_, std_, geomn_, psphericity, pttest, psignr);

end
