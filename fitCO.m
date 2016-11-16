function fitpar = fitCO(spkrmn, co_in, varargin)
% fit hyperbolic function to contrast spike rates
% 
% If blanks occured as additional condition, their average spike rate is
% taken as spontanouse firing rate. If there is none, this value must be
% fitted additionally.
% Other fitted values are c50 and the steepness factor n.
%
% The output is a struct containing fitted parameters and the explained
% variance.
%
% TODO: It would ne helpful to get a confidence interval of the fit.
%
% @CL 21.06.2016


boot_flag = false;  
if mod(length(varargin),2)==1
    spkrvar = varargin{1};
    boot_flag = 1; 
end


% index for non-blank values
co = co_in;
co(co>1000) =0;


opt = optimset('MaxIter', 10^4, 'MaxFunEvals', 10^4, 'TolFun', 0.001);


% have muliple, random starting points
n_start = 50; 
p0 = [randn(n_start,1)*5+repmat(max(spkrmn), n_start, 1), ...  % rmax 
    randn(n_start,1)/100+0.5, ...                    % c50
    rand(n_start,1)*3, ...                     % n
    abs(randn(n_start,1))*5+min(spkrmn)];         % m
p0(p0(:,2)<0, 2) = 0;
p0(p0(:,2)>1, 2) = 1;


% fitting
for i =1:n_start
    param(:, i)= fminsearch(@(p) cf(co, spkrmn, p), p0(i,:), opt);
    ss(i) = cf(co, spkrmn, param(:, i));
end

[~, mini] = min(ss);
ss = ss(mini);
param = param(:,mini);



% bootstrapping
if boot_flag
    boot_param = nan(1000, 4);
    boot_y = nan(1000, sum);
    boot_fval = nan(1000,1);
    for i = 1:1000
        spkrmn_new = getBootstrapval(spkrmn, sqrt(spkrvar));
        [boot_param(i,:), boot_fval(i)] = fminsearch(@(p) cf(co, spkrmn_new, p), param, opt);
        boot_y(i,:) = hyperratiofct( co, boot_param(i,1), boot_param(i,2), boot_param(i,3), boot_param(i,4));
    end
    
    fitpar.boot.param = boot_param;
    fitpar.boot.expVar = 1 - (boot_fval./ sum( (spkrmn - mean(spkrmn)).^2 ) );
    fitpar.boot.y_pred = boot_y;
end


% assign values to struct 
fitpar.rmax = param(1);
fitpar.c50 = param(2);
fitpar.n = param(3);
fitpar.m = param(4);
fitpar.r2 = 1 - ss / sum( (spkrmn - mean(spkrmn)).^2 );
fitpar.val = spkrmn;
fitpar.co = co;

fitpar.x = eps:0.001:1;
fitpar.y = hyperratiofct(fitpar.x, fitpar.rmax, fitpar.c50, fitpar.n, fitpar.m);
fitpar.auc = sum(hyperratiofct( 0.1:0.1:1, fitpar.rmax, fitpar.c50, fitpar.n, fitpar.m));

end



function ss = cf(x, y, param)
% cost function when baseline is unknown
% x = contrast, 
% y = spike rate means
% param = parameters to fit the hyperbolic ratio function

rmax = param(1);% maximal spike rate
c50 = param(2);    % contrast at half max response
n = param(3); % exponent determining the steepness
m = param(4);   % spontanous activity


y_pred = hyperratiofct( x, rmax, c50, n, m);

ss = sum((y_pred-y).^2);

if c50 < 0 || n < 0 || n > 100 || m<0 || c50 > 100
    ss = 10^6;
end
    
end


function ss = cf2(x, y, m, param)
% cost function when baseline is fix
% x = contrast, 
% y = spike rate means
% m = spontanous activity
% param = parameters to fit the hyperbolic ratio function


rmax = param(1); % contrast at half max response
c50 = param(2);   % exponent determining the steepness
n = param(3); % maximal spike rate

y_pred = hyperratiofct( x, rmax, c50, n, m);

ss = sum((y_pred-y).^2);


if c50<0 || c50>1 || n < 0.5 || n > 10
    ss = 10^6;
end

end


function newval = getBootstrapval(oldvalmn, oldvalvar)


newval = oldvalmn + oldvalvar.*randn(size(oldvalmn));

end
