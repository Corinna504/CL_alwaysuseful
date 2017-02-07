function exinfo = bootstrap_exinfo( exinfo )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


s1 = exinfo.ratepar;
s2 = exinfo.ratepar_drug;
[rate_base, mntc_CI_base] = getMnVr(exinfo.ratemn, exinfo.ratesd, exinfo.rawspkrate, s1, s2);
[rate_drug, mntc_CI_drug] = getMnVr(exinfo.ratemn_drug, exinfo.ratesd_drug, exinfo.rawspkrate, s2, s1);


exinfo.nonparam_ratio = mean(rate_drug)/mean(rate_base);
exinfo.mntc_CI_base = evaluateBooty(boot_base); 
exinfo.mntc_CI_drug = evaluateBooty(boot_drug); 

end


function [mn, ci] = getMnVr(mn, resmpls, i1, i2)
%returns data with similar rate 
idx = ismember(i1, i2);
mn = mn(idx); % mean spike rate (across raw tc)
resmpls = resmpls(idx); % resamples, cell array

for i = 1:length(resmpls)
    mn_res(i,:) = mean(resmpls{i}, 2);
end
mn_res = mean(mn_res,2);

ci = getCI(mn_res);
end


function ci = getCI(y)
% 5 and 95% intervals
ci(1) = prctile(y, 5);
ci(2) = prctile(y, 95);

end