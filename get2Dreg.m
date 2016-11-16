function [slope, offset] = get2Dreg(exinfo)


netspk = exinfo.sdfs.mn_rate(1).mn;
netspk_drug = exinfo.sdfs_drug.mn_rate(1).mn;

x = fminsearch(@(x) cf(x, netspk, netspk_drug),[1 0]);

slope = x(1);
offset = x(2);

end





function ols = cf(x, netspk, netspk_drug)

yfit = netspk.*x(1)+x(2);
ols = sum( sum((netspk_drug-yfit).^2 ));

end