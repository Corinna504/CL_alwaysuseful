function [ fitpar, gof2 ] = fitgaussequalmu2( spkRates, spkRates_drug, theta)
%onegaussfit2 
% fits gauss in a range of 180deg. Compared to onegausfit1, this function
% collapses the data with having two points, one mean for each range  [0
% 170], rsptl. [180 350]

%%% Fitting orientation tuning curves to gauss function
%
% 
% explanation:  
% f(x) = a*exp( -0.5 * ((x-mu) / sig).^2 ) + b


%%% collapse data
theta_val = mod(theta, 180);


%%% fit data to gauss
mu0 = theta_val(max(spkRates) == spkRates);
x0 = [mu0 90 90 1 1 0 0];
            
            
fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', zeros(1,7), ...
               'Upper',[360  1000 1000 100 100 100 100],...
               'StartPoint', x0); 

ft = fittype(@(mu, sig_base, sig_drug, a_base, a_drug, b_base, b_drug, x) ...
               fitsimultan(mu, sig_base, sig_drug, a_base, a_drug, b_base, b_drug, x),...
               'options', fo);
          
[fitpar,gof2] = fit([theta_val theta_val]', [spkRates spkRates_drug]',ft);




%%% plot results
figure('Position', [570   391   650   577]);

rg = fitpar.mu-90 : 5 : fitpar.mu+90;
y_base = gaussian(fitpar.mu, fitpar.sig_base, fitpar.a_base, fitpar.b_base, rg);
y_drug = gaussian(fitpar.mu, fitpar.sig_drug, fitpar.a_drug, fitpar.b_drug, rg);

ymax = max([spkRates, spkRates_drug, y_base, y_drug]);
ymax = ymax+ymax/10;
yrg = [0 ymax];

% --------------------------------- raw data
s(1) = subplot(2,2,[1 2]);

plot(theta, spkRates, 'or-', 'MarkerFaceColor', 'r'); hold on   %baseline
plot(theta, spkRates_drug, 'or--');                             % drug
plot([180 180], yrg, 'k');
xlim([0 360]);

title([struct2title(fitpar) sprintf(' r2=%1.2f', gof2.rsquare)]);
legend('baseline', 'drug');

% --------------------------------- collapsed raw data
s(2) = subplot(2,2,3);

lb = find(theta <  180) ;
ub = find(theta >=  180) ;

% predefinitions
theta_val( theta_val < fitpar.mu -90 ) = theta_val( theta_val < fitpar.mu -90 ) + 180;
theta_val( theta_val > fitpar.mu +90 ) = theta_val( theta_val > fitpar.mu +90 ) - 180;

%sort x-scale
[t, ix, ~] = unique(theta_val(lb));

plot(t, spkRates( lb(ix) ), 'or-', 'MarkerFaceColor', 'r'); hold on
plot(t, spkRates_drug( lb(ix) ), 'or--');

if ~isempty(ub) 
    [t, ix, ~] = unique(theta_val(ub));
    
    plot(t, spkRates_drug( ub(ix) ), 'or--');
    plot(t, spkRates( ub(ix) ), 'or-', 'MarkerFaceColor', 'r'); hold on
end

xlim([min(rg) max(rg)]);
title('collapsed tuning curve')


% --------------------------------- fitted data
s(3) = subplot(2,2,4);

plot(rg, y_base, 'r-', 'MarkerFaceColor', 'r'); hold on
plot(theta_val, spkRates, 'or', 'MarkerFaceColor', 'r'); hold on
plot(rg, y_drug, 'r--');
plot(theta_val, spkRates_drug, 'or');

xlim([min(rg) max(rg)]);
title('fitted gauss');

% --------------------------------- general
for i=1:3
    plot(s(i), [fitpar.mu fitpar.mu], yrg, '--', 'Color', [0.8 0.8 0.8]);
    plot(s(i), [fitpar.mu fitpar.mu]+180, yrg, '--', 'Color', [0.8 0.8 0.8]);
    plot(s(i), [fitpar.mu fitpar.mu]-180, yrg, '--', 'Color', [0.8 0.8 0.8]);
end
set(s, 'ylim', [0, ymax] );

end


function y = fitsimultan(mu, sig_base, sig_drug, a_base, a_drug, b_base, b_drug, x)
% calculates the gaussian function simultaniously for drug and baseline
% condition

x1 = x(1:length(x)/2);
x2 = x(length(x)/2 + 1:end);

y = [gaussian(mu, sig_base, a_base, b_base, x1);...
    gaussian(mu, sig_drug, a_drug, b_drug, x2)];
end




