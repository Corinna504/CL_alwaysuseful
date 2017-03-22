function fitparam = fitCO(mn, co_in, bootstrp)
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
%
% @CL 21.06.2016

% index for non-blank values
co = co_in(co_in<=1);
mn = mn(co_in<=1);

% fit settings
opt = optimset('MaxIter', 10^4, 'MaxFunEvals', 10^4, 'TolFun', 0.001, 'Display', 'off');

% have muliple, random starting points
n_start = 20; 
p0 = [randn(n_start, 1).* repmat(max(mn), n_start, 1), ...  % rmax 
    abs(randn(n_start,1))+0.1, ...                    % c50
    abs(randn(n_start,1)), ...                     % n
    abs(randn(n_start,1))*5+min(mn)];         % m
p0(p0(:,2)<0, 2) = 0; % don't start with c50 smaller than 0
p0(p0(:,2)>1, 2) = 1; % don't start with c50>1

% fitting
parfor i =1:n_start
    param(:, i)= fminsearch(@(p) cf(co, mn, p), p0(i,:), opt);
    ss(i) = cf(co, mn, param(:, i));
end

% choose the best fit according to the squared error
[~, mini] = min(ss);
ss = ss(mini);
param = param(:,mini);


% assign values to struct 
fitparam.rmax = param(1);
fitparam.c50 = param(2);
fitparam.n = param(3);
fitparam.m = param(4);
fitparam.r2 = 1 - ss / sum( (mn - mean(mn)).^2 );
fitparam.val = mn;
fitparam.co = co;

fitparam.x = 0:0.001:1;
fitparam.y = hyperratiofct(fitparam.x, fitparam.rmax, fitparam.c50, fitparam.n, fitparam.m);
fitparam.auc = sum(hyperratiofct( 0.1:0.1:1, fitparam.rmax, fitparam.c50, fitparam.n, fitparam.m));


if nargin==3
    parfor i = 1:1000
        bootidx = randi(length(mn), length(mn), 1); 
        boot(i).fitparam = fitCO(mn(bootidx), co_in(bootidx));
    end
    fitparam.boot = boot;
end


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


y_pred = hyperratiofct( x, rmax, c50, n, m); % predicted data

ss = sum((y_pred-y).^2);        % summed squared error, i.e. the general cost function 


% restrictions / boundaries
if c50 < 0 || n < 0 || m<0 || rmax <0 %|| rmax+m > max(y) 
    ss = Inf;
end
    
end


