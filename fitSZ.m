function fitparam = fitSZ( mn, sem, sz )
% assigns the critical parameters and estimates to the fitparam structure
%
%
%
%

idx = sz<1000;
sz=sz(idx); mn2 = mn(idx)-mn(~idx); sem = sem(idx);
sz = (sz./2)*10;

% [FitPa,fval,exitflag,fitx,fity] = FitRatioOfGaussians(sz, mn2);
% 
% fitparam.val.mn = mn(idx);
% fitparam.val.sem = sem;
% fitparam.val.sz = sz;
% fitparam.val.x = 0:0.01:sz(end);
% 
% fitparam.val.y =  MyRatioOfGaussians([FitPa.w_c, FitPa.w_s, FitPa.k_c, FitPa.k_s], ...
%     fitparam.val.x)+mn(~idx);
% 
% fitparam.SI = (max(mn2)-mn2(end)) /  max(mn2);
% fitparam.mu = getPSZ(fitparam.val.y , fitparam.val.x);
% fitparam.r2 = fval;
% 
% 
% figure;
% errorbar( fitparam.val.sz,fitparam.val.mn, fitparam.val.sem); ho
% plot( fitparam.val.x, fitparam.val.y);

% CL fit
[ks, kc, ws, wc, fvalcl, r2] = fitGaussRatio(sz, mn2);
% sz = sz/10; wc=wc/10; ws=ws/10;

%  assign results
fitparam.val.mn = mn(idx);
fitparam.val.sem = sem;
fitparam.val.sz = sz;

fitparam.val.x = 0:0.01:sz(end);
fitparam.val.y = GaussRatio(ks, kc, ws, wc, fitparam.val.x)+mn(~idx);
fitparam.wc = wc; 
fitparam.ws = ws; 
fitparam.ks = ks; 
fitparam.kc = kc; 

fitparam.SI = (max(mn2)-mn2(end)) /  max(mn2);

fitparam.mu = getPSZ(fitparam.val.y , fitparam.val.x, mn(idx), sz);
fitparam.r2 = r2;

% hold on;
% errorbar( fitparam.val.sz,fitparam.val.mn, fitparam.val.sem); ho
% plot( fitparam.val.x, fitparam.val.y);
% legend('data', 'cl fit');
% 
% title(sprintf(['pref sz : %1.2f, SI= %1.2f \n' ....
%     '\n clfit wc=%1.1f, ws=%1.1f, kc=%1.1f, ks=%1.1f, fval=%1.2f, r2=%1.2f'],...
%     fitparam.mu, fitparam.SI, ...
%     fitparam.wc, fitparam.ws, fitparam.kc, fitparam.ks, fvalcl, r2));
% xlabel('size'), ylabel('spks/s');

end
 

function prefsz = getPSZ(rfit, szfit, r, sz)
% the preferred size is the smallest radius at which
% the response exceeds 98% of the unit’s maximum response based on the
% fitted data.

[~, sortidx] = sort(sz);
r = r(sortidx);

[~, idxmax] = max(r);
if idxmax==1
    prefsz = sz(1);
else
    idx = find( rfit > 0.98*max(rfit), 1, 'first'); % get index of first response > 98%
    if isempty(idx)
        prefsz = sz(1);
    else
        prefsz = szfit(idx); % assign preferred size to output
    end
end

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
 