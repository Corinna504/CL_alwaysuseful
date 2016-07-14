%% analyse the effect of dose and time

dat = DoseResponse();
dat2 = dat( [ dat.numinexp ] <=8 );


%% look at correlations first:
clc
ind1 = [dat2.is5HT];
ind2 = ~ind1 & [dat2.numinexp]>1;

% rel frate
[r, p] = corr([dat2(ind1).dose]', [dat2(ind1).relfrate]', 'type', 'pearson');
disp(sprintf('\n\n5HT only: dose vs. rel gain: rho=%1.3f (p=%1.3f)', r, p));

[r, p] = corr([dat2(ind1).numinexp]', [dat2(ind1).relfrate]', 'type', 'pearson');
disp(sprintf('5HT only: order vs. rel gain: rho=%1.3f (p=%1.3f)', r, p));
% ploterr( dat, 'numinexp' )

[r, p] = corr([dat2(ind2).numinexp]', [dat2(ind2).relfrate]', 'type', 'pearson');
disp(sprintf('Base only: order vs. rel gain: rho=%1.3f (p=%1.3f)', r, p));
% ploterr( dat, 'numinexp' )


% modulation index
[r, p] = corr([dat2(ind1).dose]', [dat2(ind1).moduidx]', 'type', 'pearson');
disp(sprintf('\n\n5HT only: dose vs. MI: rho=%1.3f (p=%1.3f)', r, p));
% ploterr( dat, 'numinexp', 'depvar', 'moduidx')

[r, p] = corr([dat2(ind2).numinexp]', [dat2(ind2).moduidx]', 'type', 'pearson');
disp(sprintf('5HT only: order vs. MI: rho=%1.3f (p=%1.3f)', r, p));

[r, p] = corr([dat2(ind2).timerel2strt]', [dat2(ind2).moduidx]', 'type', 'pearson');
disp(sprintf('Base only: time vs. MI: rho=%1.3f (p=%1.3f)', r, p));




%% extract residuals of gain and correlate with dose and time
clc
disp(sprintf('\n\n residuals of relative gain after removing trial number effect \n \n '));

beta = corrcoef([dat2.numinexp]', [dat2.relfrate]');
beta = beta(2,1);

alpha = mean([dat2.relfrate]) - mean([dat2.numinexp])*beta;
y_new = ([dat2.relfrate]'-(alpha+[dat2.numinexp]'*beta));

[r, p] = corrcoef(y_new, [dat2.dose]');
disp(sprintf('res vs. dose: rho=%1.3f (p=%1.3f) \n', r(2,1), p(2,1)));

[r, p] = corrcoef(y_new([dat2.is5HT]), [dat2([dat2.is5HT]).dose]');
disp(sprintf('5HT only: res vs. dose: rho=%1.3f (p=%1.3f) \n', r(2,1), p(2,1)));

[r, p] = corrcoef(y_new(~[dat2.is5HT]), [dat2(~[dat2.is5HT]).dose]');
disp(sprintf('Control only: res vs. dose: rho=%1.3f (p=%1.3f) \n', r(2,1), p(2,1)));


%%%
disp(sprintf('\n\n same for residuals after removing dose effect \n \n '));

beta = corrcoef([dat2.dose]', [dat2.relfrate]');
beta = beta(2,1);

alpha = mean([dat2.relfrate]) - mean([dat2.dose])*beta;
y_new = ([dat2.relfrate]'-(alpha+[dat2.dose]'*beta));

[r, p] = corrcoef(y_new, [dat2.numinexp]');
disp(sprintf('res vs. numinexp: rho=%1.3f (p=%1.3f) \n', r(2,1), p(2,1)));

[r, p] = corrcoef(y_new([dat2.is5HT]), [dat2([dat2.is5HT]).numinexp]');
disp(sprintf('5HT only: res vs. numinexp: rho=%1.3f (p=%1.3f) \n', r(2,1), p(2,1)));

[r, p] = corrcoef(y_new(~[dat2.is5HT]), [dat2(~[dat2.is5HT]).numinexp]');
disp(sprintf('Control only: res vs. numinexp: rho=%1.3f (p=%1.3f) \n', r(2,1), p(2,1)));



%% 

lmdat = table([dat2.timerel2strt]', [dat2.numinexp]',[dat2.moduidx]',...
    [dat2.relfrate]', [dat2.dose]', [dat2.is5HT]',...
    'VariableNames',{'time', 'order','MI','relgain', 'dose', 'is5ht'});
lmdat.is5ht = categorical(lmdat.is5ht);

%%
clc

disp('Rel Gain~...');


lm_dose = fitglm(lmdat, 'relgain~-1+dose'); lm_dose.Coefficients %sig

lm_time = fitlm(lmdat, 'relgain~-1+time');  lm_time.Coefficients %not sig
lm_order = fitlm(lmdat, 'relgain~1+order*is5ht'); lm_order.Coefficients %not sig

lm_dose2 = fitlm(lmdat, 'relgain~-1+dose*time'); lm_dose2.Coefficients %only time sig, without interaction, both are sig
lm_dose3 = fitlm(lmdat, 'relgain~-1+dose*order'); lm_dose3.Coefficients %both sig (dose<.08), no interaction


plotSlice(lm_dose3)

%%
clc

disp('MI~...');
lm_midose = fitglm(lmdat, 'MI~-1+dose'); lm_midose.Coefficients %sig

lm_mitime = fitlm(lmdat, 'MI~-1+time');  lm_mitime.Coefficients %not sig
lm_miorder = fitlm(lmdat, 'MI~-1+order'); lm_miorder.Coefficients %not sig

lm_midose2 = fitlm(lmdat, 'MI~-1+dose*time'); lm_midose2.Coefficients
lm_midose3 = fitlm(lmdat, 'MI~-1+dose*order'); lm_midose3.Coefficients



plotSlice(lm_midose3)
