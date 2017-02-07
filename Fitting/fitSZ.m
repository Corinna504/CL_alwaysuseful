function fitparam = fitSZ( mn, sem, sz )
% assigns the critical parameters and estimates to the fitparam structure
%
%
%
%

idx = sz<1000;
sz2=sz(idx); 
mn2 = mn(idx); offset = min(mn2); mn2 = mn2-offset;
sem2 = sem(idx);

sz_4fit = sz2 ;%.*5;


% CL fit
[ks, kc, ws, wc, fvalcl, r2] = fitGaussRatio(sz_4fit, mn2);
% sz = sz/10; wc=wc/10; ws=ws/10;

%  assign results
fitparam.val.mn = mn(idx);
fitparam.val.sem = sem2;
fitparam.val.sz = sz2;

fitparam.val.x = 0:0.01:sz2(end);
fitparam.val.y = GaussRatio(ks, kc, ws, wc, fitparam.val.x)+offset;
fitparam.wc = wc; 
fitparam.ws = ws; 
fitparam.ks = ks; 
fitparam.kc = kc; 

mn4si = mn(idx)-mn(~idx);
fitparam.SI = (max(mn4si)-mn4si(end)) /  max(mn4si);

fitparam.mu = getPSZ(fitparam.val.y , fitparam.val.x, mn(idx), sz2);
fitparam.r2 = r2;

fprintf('SI %1.2f \n', fitparam.SI)

end



function prefsz = getPSZ(rfit, szfit, r, sz)
% the preferred size is the smallest radius at which
% the response exceeds 98% of the unit�s maximum response based on the
% fitted data.

[~, sortidx] = sort(sz);
r = r(sortidx);

[~, idxmax] = max(r);
if idxmax==1
    prefsz = sz(1);
else
    idx = find( rfit > 0.98*max(rfit), 1, 'first'); % get index of first response > 98%
    if isempty(idx)
        prefsz = -1;
    else
        prefsz = szfit(idx); % assign preferred size to output
    end
end

fprintf('pref sz %1.2f \n', prefsz)
end


% 
%  
% function Q = MyRatioOfGaussians(X0,x)
% 
% f1 = @(t1) exp(-(t1/X0(1)).^2);
% f2 = @(t2) exp(-(t2/X0(2)).^2);
% for n=1:length(x)
% Q(n) = X0(3)*(2/sqrt(pi)*integral(f1,0,x(n)))^2/...
%     (1+(2/sqrt(pi)*X0(4)*integral(f2,0,x(n)))^2);
% end
% 
% end
%  
 