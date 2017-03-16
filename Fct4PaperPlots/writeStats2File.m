function stats = writeStats2File(s, fname)
% writes the staticts s attached to a plot from mugui into a text file with
% the given filename fname and reads out the main values relevant for the
% plot

fileID = fopen([fname(1:end-3) 'txt'],  'wt');
fprintf(fileID, '%s\n', s);
fclose(fileID);

%%% read statistics into an array
% n 5HT
[~,idxn]  = regexp(s, 'N = '); 
i5ht = idxn(1); l = 3;
while ~isempty(strfind( s( i5ht:i5ht+l ), ')')) && l>0
    l = l-1;
end
stats.n5HT = str2double( s( i5ht:i5ht+l ) );

% n NaCl
inacl = idxn(3); l = 3;
while ~isempty(strfind( s( inacl:inacl+l ), ')')) && l>0
    l = l-1;
end
stats.nNaCl = str2double( s( inacl:inacl+l ) );


% paired signrank p value
[stats.p5HT, stats.pNaCl, stats.p5HTvsNaClx, stats.p5HTvsNaCly]  = ...
    getSampleTest(s);


% correlation rho and p value
[stats.spearmanRho5HT, stats.spearmanP5HT, stats.spearmanRhoNaCl, stats.spearmanPNaCl] = ...
    getCorrStats(s, 'Spearman: rho=');
[stats.pearsonRho5HT, stats.pearsonP5HT, stats.pearsonRhoNaCl, stats.pearsonPNaCl] = ...
    getCorrStats(s, 'Pearson: rho=');
end




function [rho5HT, p5HT, rhoNaCl, pNaCl] = getCorrStats(s, fname)
% extract correlation rho and p value
l = 6;
l2 = 13;

[~,idxp]  = regexp(s, fname);  idxp = idxp+1;
rho5HT = str2double( s( idxp(1):idxp(1)+l ) );
rhoNaCl = str2double( s( idxp(2):idxp(2)+l ) );

if rho5HT>=0
    p5HT = str2double( s( idxp(1)+l+5:idxp(1)+l2 ) );
else
    p5HT = str2double( s( idxp(1)+l+6:idxp(1)+l2+1 ) );
end

if rhoNaCl>=0
    pNaCl = str2double( s( idxp(2)+l+5:idxp(2)+l2 ) );
else
    pNaCl = str2double( s( idxp(2)+l+6:idxp(2)+l2+1 ) );
end

end



function [p5HTxy, pNaClxy, p5HTvsNaClx, p5HTvsNaCly] = getSampleTest(s)


alpha = 0.05; % alpha level
l_ks = 5; l_test = 7;

% test indeces
% indeces for paired tests
[~,idxPairedSR]  = regexp(s, 'paired signrank p=');  idxPairedSR = idxPairedSR+1; % non-parametric
[~,idxPairedTT]  = regexp(s, 'paired t-test p=');  idxPairedTT = idxPairedTT+1; % parametric 

% indeces for two sample tests
[~,idxp2sTT]  = regexp(s, '2-sample ttest p='); idxp2sTT = idxp2sTT+1; % parametric
[~,idxp2sW]  = regexp(s, 'wilcoxon p='); idxp2sW = idxp2sW+1;  % non-parametric


% entries containing the test p-Value for normal distributio
% if p>alpha, than the sample is assumed normally distributed
[~,idxp]  = regexp(s, 'test for normal dist p=');  idxp = idxp+1;
kstest_p_5HTx = str2double( s( idxp(1):idxp(1)+l_ks ) );
kstest_p_5HTy = str2double( s( idxp(2):idxp(2)+l_ks ) );
kstest_p_NaClx = str2double( s( idxp(3):idxp(3)+l_ks ) );
kstest_p_NaCly = str2double( s( idxp(4):idxp(4)+l_ks ) );


% test for normal distribution concerning both samples (5HT and NaCl)
if kstest_p_5HTx>alpha && kstest_p_NaClx > alpha
    p5HTvsNaClx = str2double( s( idxp2sTT(1):idxp2sTT(1)+l_test ) ); % assuming normal distribution
else
    p5HTvsNaClx = -str2double( s( idxp2sW(1):idxp2sW(1)+l_test ) );
end

if kstest_p_5HTy>alpha && kstest_p_NaCly > alpha
    p5HTvsNaCly = str2double( s( idxp2sTT(2):idxp2sTT(2)+l_test ) );% assuming normal distribution
else
    p5HTvsNaCly = -str2double( s( idxp2sW(2):idxp2sW(2)+l_test ) );
end 


% test for normal distribution concerning paired samples (5HT or NaCl)
[~,idxp]  = regexp(s, 'normal dist X-Y h=');  idxp = idxp+1;
kstest_h_5HTxy = str2double( s( idxp(1):idxp(1)+1 ) );
kstest_h_NaClxy = str2double( s( idxp(2):idxp(2)+1 ) );

% if h is 1, the hypotheses that claims normal distribution is rejected
% i.e., if h is 0, the normal distribution is assumed
if ~kstest_h_5HTxy
    p5HTxy = str2double( s( idxPairedTT(1):idxPairedTT(1)+l_test ) ); % assuming normal distribution
else
    p5HTxy = -str2double( s( idxPairedSR(1):idxPairedSR(1)+l_test ) );
end

if ~kstest_h_NaClxy
    pNaClxy = str2double( s( idxPairedTT(2):idxPairedTT(2)+l_test ) );% assuming normal distribution
else
    pNaClxy = -str2double( s( idxPairedSR(2):idxPairedSR(2)+l_test ) );
end



end










