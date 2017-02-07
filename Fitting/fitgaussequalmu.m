function [ fitpar ] = fitgaussequalmu( spkRates, spkRates_drug, theta, p_flag)
%onegaussfit 

%%% Fitting orientation tuning curves to gauss function
%
% 
% explanation:  
% f(x) = a*exp( -0.5 * ((x-mu) / sig).^2 ) + b

if nargin == 3
    p_flag = 0;
end

% collapse data
theta_mod = mod(theta, 180);
theta_val = unique(theta_mod);

for i = 1:length(theta_val)
   mnrate(i) = mean( [spkRates{theta_mod == theta_val(i) }] );
   sdrate(i) = std( [spkRates{theta_mod == theta_val(i) }] );
   
   mnrate_drug(i) = mean( [spkRates_drug{theta_mod == theta_val(i) }] );
   sdrate_drug(i) = std( [spkRates{theta_mod == theta_val(i) }] );

end



% fit data to gauss
mu0 = mean( [theta_val(max(mnrate) == mnrate) , ...
    theta_val(max(mnrate_drug) == mnrate_drug) ]);
x0 = [mu0 90 90 1 1 0 0];
            
            
fo = fitoptions('Method','NonlinearLeastSquares',...
              'Lower', zeros(1,7), ...
               'Upper',[360  inf inf 100 100 100 100],...
               'StartPoint', x0); 

ft = fittype(@(mu, sig_base, sig_drug, a_base, a_drug, b_base, b_drug, x) ...
               fitsimultan(mu, sig_base, sig_drug, a_base, a_drug, b_base, b_drug, x),...
               'options', fo);
          
[fitpar,fiteval,gof2] = fit([theta_val theta_val]', [mnrate mnrate_drug]',ft);


% plot results
if p_flag
    figure
    % raw data
    subplot(2,1,1)
    plot(theta, cellfun(@mean, spkRates), 'or-', 'MarkerFaceColor', 'r'); hold on
    plot(theta, cellfun(@mean, spkRates_drug), 'or--');
    title([struct2title(fitpar) sprintf(' r2=%1.2f', fiteval.rsquare)]);
    
    % fitted data
    
    rg = fitpar.mu-90 : 5 : fitpar.mu+90;
    y_base = gaussian(fitpar.mu, fitpar.sig_base, fitpar.a_base, fitpar.b_base, rg);
    y_drug = gaussian(fitpar.mu, fitpar.sig_drug, fitpar.a_drug, fitpar.b_drug, rg);
    theta_val( theta_val < fitpar.mu -90 ) = theta_val( theta_val < fitpar.mu -90 ) + 180;
    theta_val( theta_val > fitpar.mu +90 ) = theta_val( theta_val > fitpar.mu +90 ) - 180;
    
    subplot(2,1,2)
    plot(rg, y_base, 'r-', 'MarkerFaceColor', 'r'); hold on
    errorbar(theta_val, mnrate, sdrate, 'or', 'MarkerFaceColor', 'r'); hold on
    
    plot(rg, y_drug, 'r--');
    errorbar(theta_val, mnrate_drug,sdrate_drug, 'or');
end
end

function y = fitsimultan(mu, sig_base, sig_drug, a_base, a_drug, b_base, b_drug, x)
% calculates the gaussian function simultaniously for drug and baseline
% condition

x1 = x(1:length(x)/2);
x2 = x(length(x)/2 + 1:end);

y = [gaussian(mu, sig_base, a_base, b_base, x1);...
    gaussian(mu, sig_drug, a_drug, b_drug, x2)];
end


