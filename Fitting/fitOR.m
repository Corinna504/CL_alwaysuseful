function fitpar = fitOR( spkmn, spksem, or)
%fitgauss fits incoming spike rates to the orientation data

i_noblank = or < 180;
or = or(i_noblank);
mn = spkmn(i_noblank);
sem = spksem(i_noblank);


%%% center around highest peak 
pk = or(find(max(mn) == mn, 1, 'first'));
[val.or, val.mn, val.sem] = centerData(or, mn, sem, pk);

%%% fit the gaussian function to the mean responses 
[fit_res,~] = fitHelper(pk, val);


%%% repeat the previouse two steps to center around the true mean
[val.or, val.mn, val.sem] = centerData(or, mn, sem, fit_res.mu);
[fit_res,gof2] = fitHelper(fit_res.mu, val);


%%% assign the data
fitpar.mu = fit_res.mu;        fitpar.sig = fit_res.sig;
fitpar.a = fit_res.a;          fitpar.b = fit_res.b;
fitpar.r2 = gof2.rsquare;

% shift the orientation data if the preferred orientation is outside 0-180 window
if fitpar.mu > 180 
    fitpar.mu = fitpar.mu -180;
    val.or = val.or-180;
elseif  fitpar.mu < 0
    fitpar.mu = fitpar.mu +180;
    val.or = val.or+180;
end


fitpar.val = val;
fitpar.x = fitpar.mu-100:fitpar.mu+100;
fitpar.y = gaussian(fitpar.mu, fitpar.sig, fitpar.a, fitpar.b, fitpar.x) ;

end


function [fit_res,gof2] = fitHelper(pk, val)

%%% fit data to gauss
x0 = [pk 90 max(val.mn)-min(val.mn) 0]; % starting point
fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', [pk-100 0 min(val.mn)/2 0], 'Upper',[pk+100  180 2*max(val.mn) min(val.mn)*1.5],...
               'StartPoint', x0, 'MaxFunEvals', 10^5, 'MaxIter', 10^5); 
ft = fittype(@(mu, sig, a, b, x) gaussian(mu, sig, a, b, x), 'options', fo);
          

% fit parameters
[fit_res,gof2] = fit(val.or, val.mn, ft);

end




function [or, mn, sem] = centerData(or, mn, sem, pk)
%%% center around peak 

or(or > pk+90) = or(or > pk+90) -180;
or(or < pk-90) = or(or < pk-90) +180;

[or, idx] = sort(or);
mn = mn(idx);
sem = sem(idx);

or=or'; sem=sem'; mn=mn';
end