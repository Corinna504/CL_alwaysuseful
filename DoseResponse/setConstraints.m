function dat = setConstraints(dat)

reg_r2 = .7; % regression fit
dat = dat([dat.regr2] > reg_r2);


tc_r2 = .7; % tuning fit
for i =1:length(dat)
    tc_idx(i) = dat(i).fitparam.r2 > tc_r2;
end
dat = dat(tc_idx);


% remove the files with missing dose
doseidx = [find([dat.dose]<=0 & [dat.is5HT]), find([dat.dose]<=0 & [dat.is5HT])-1];
idx = true(1, length(dat)); idx(doseidx) = 0;
dat  = dat(idx);


% remove the files with NaCl
is5HT = [find([dat.is5HT]), find([dat.is5HT])-1, find([dat.numinexp]==1)];
dat  = dat(sort(is5HT));


fprintf('final n = %1.0f \n', length(dat));
end

