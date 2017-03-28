function [ks, kc, ws, wc, fval, r2] = fitGaussRatio(sz, r)
% This function implements a fitting algorithm to adjust the ratio of
% gaussians (Cavanaugh et al. 2002) to the raw size tuning.
% It calls the function GaussRatio(ks, kc, ws, wc, sz) with
%
% - ks the gain of the suppressin
% - kc the gain of the excitation
% - ws the width of the suppressive surround gaussian 
% - wc the width of the excitatort central gaussian 
% - sz the stimulus size   
%
% The fit aims to minimize the residuals between predicted and true
% responses (see cost function, cf) and is constraint with all parameters > 0
% and wc>ws.
% 
% Note that the algorithm is highly dependent on the starting values. 
% Because of this, first the width of the gaussians are determined with
% fixed ks and kc values, than the gain values.
%
% @CL 27.10.2016
%
%
% update @CL 7.11.2016
% Finding a good fit is facilitated by using the square of ks, therefore it
% is taking ks^2 in the cost function. Also, 100 random values around
% given, 'good' starting values are tested for the best fit.
%

rng(9123234); % to always end up with the same fit in repetitive batches

opt = optimset('MaxFunEvals',2000,'maxiter',2000, 'Display', 'off');

% the starting width of the center gaussian is the radius of the stimulus
% that elicited the first peak response in the raw tuning curve
idx = find( r>max(r)*0.7, 1, 'first');
if ~isempty(idx)
    wc = sz(idx);
else
    wc = sz(1);
end


x0 = [wc, wc+0.3, 10, 0.0001; ...
    wc, wc+1, 1, 0.0001; ...
    wc, wc+0.3, 1, 0.0001; ...
    wc, wc+1, 10, 0.01; ...
    wc, wc+1, 1, 0.01; ...
    wc, wc+1, 20, 0.01; ...
    wc, wc+0.3, 20, 0.01; ...
    wc, wc+0.3, 1, 0.01];


parfor i = 1:size(x0,1)
    [p(i,:), fval(i)] = fminsearch(@cf, x0(i,:), opt, sz, r);
end

[~, winneri] = min(fval);
pfin = p(winneri, :); fval = fval(winneri);

fprintf('sz fit winner #%1.0f \n', winneri)


%assign parameters
wc = pfin(1,1); ws = pfin(1,2);
kc = pfin(1,3); ks = pfin(1,4)^2;

% compute explained variance
r_pred = GaussRatio(ks, kc, ws, wc, sz);
if size(r,1) ~= size(r_pred, 1)
        r = r';
end
r2 = 1- ((sum((r_pred-r).^2)  / sum( (r-mean(r)).^2 ) ));


end


%% COST FUNCTION
function cost = cf(p, sz, r)
% cost function for all parameters
% note, the fit is restricted to wc<ws, i.e. the center is smaller than
% surround

wc = p(1); ws = p(2);
kc = p(3); ks = p(4)^2;

r_pred = GaussRatio(ks, kc, ws, wc, sz);
if wc>ws || wc<0 || ws<0 || ks<0 || kc<0 
    cost = inf;
else
    if size(r,1) ~= size(r_pred, 1)
        r = r';
    end
    cost = sum( (r_pred-r).^2);
end
        
end




 