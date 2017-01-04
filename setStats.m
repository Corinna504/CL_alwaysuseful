function s = setStats( h )
% adds a string to the figure handle h's UserData with all statistical tests and their
% results for the attached data set. The % string can be called via h.UserData.Stats
% 
% It contains the two-sample results (5HT vs. NaCl) and the paired test
% results for each condition (Baselin vs 5HT, Baseline vs NaCl) for both
% and each individual monkey.
%

dat = h.UserData;
idx = [dat.expInfo.is5HT];
xlab=dat.xlab; ylab =dat.ylab;

%%% all
s = getStatsHelper(dat.x, dat.y, idx, xlab, ylab);

%%% mango
idx2 =[dat.expInfo.ismango];
s_ma = getStatsHelper(dat.x(idx2), dat.y(idx2), idx(idx2), xlab, ylab);

%%% kaki
idx2 =~[dat.expInfo.ismango];
s_ka = getStatsHelper(dat.x(idx2), dat.y(idx2), idx(idx2), xlab, ylab);


% save in User Data
dat.Stats = sprintf(['ALL \n' s '\n\n' 'MANGO \n' s_ma 'KAKI \n' s_ka]);
set(h, 'UserData', dat);
end


function s = getStatsHelper(x, y, idx, xlab, ylab)
% calls the statistics for a particular data set
s_5HT = getStatsPairedSample(x(idx), y(idx), '5HT');
s_NaCl = getStatsPairedSample(x(~idx), y(~idx), 'NaCl');

s_x = getStatsTwoSample(x(idx), x(~idx));
s_y = getStatsTwoSample(y(idx), y(~idx));

s = [s_5HT s_NaCl, xlab ' ' s_x  ylab ' ' s_y];
end


function s = getStatsTwoSample(sero, nat)
% two sample comparison
[~, ptt] = ttest2(sero, nat);
pwil = ranksum(sero, nat);

s = sprintf('2-sample ttest p=%1.2f, wilcoxon p=%1.2f \n\n', ptt, pwil);
end



function s = getStatsPairedSample(B, D, drugname)
% paired comparison
s_base  = getDistParam(B);
s_drug = getDistParam(D);

[~, ptt] = ttest(B, D);   psr = signrank(B, D);


s = sprintf(['Baseline' s_base drugname s_drug ...
    'paired t-test p=%1.2f, paired signrank p=%1.2f \n\n\n' ], ptt, psr);

end




function s = getDistParam(A)

n = length(A);

% distribution values
med_ = nanmedian(A);
quar_ =  quantile(A, [.25 .75]);

mn_ = nanmean(A);
std_ = nanstd(A);

geomn_ = geomean(A);
    
% check for normal distribution
[~,psphericity] = kstest(A);

% test for significant difference to normal distribution 
[~, pttest] = ttest(A, 0);   
psignr = signrank(A);


s = sprintf(['(N = %1.0f), median: %1.2f, quartile: %1.2f %1.2f, mean: %1.2f +- %1.2f SD, GM: %1.2f \n\n' ...
    'test for normal dist p= %1.2f, t-test vs. 0 p = %1.2f, signrank test vs 0: %1.2f \n\n'], ...
    n, med_,quar_, mn_, std_, geomn_, psphericity, pttest, psignr);

end