function [ fitpar, r2, val ] = fitgauss( spkmn, spksd, theta, hnfit, val )
%fitgauss fits incoming spike rates to the orientation data


theta   = theta( theta < 370 );    % ignore blanks
spkmn   = spkmn( theta < 370 );
spksd  = spksd( theta < 370 );

theta_val = mod(theta, 180);        % collapse data
uqang = unique(theta_val);

%%% get mean and standard deviation of collapsed data
if nargin < 4
    for i = 1:length(uqang)
        val.mn(i, 1)    = spkmn( theta_val == uqang(i) );
        val.sd(i, 1)   = spksd(theta_val == uqang(i));
    end
else
    uqang = val.uqang;
end


%%% center around data with highest peak
pk = uqang(find(max(val.mn) == val.mn, 1, 'first'));

uqang(uqang <= pk-90) = uqang(uqang <= pk-90) +180;
uqang(uqang >= pk+90) = uqang(uqang >= pk+90) -180;

[val.uqang, idx] = sort(uqang);
val.mn = val.mn(idx);
val.sd = val.sd(idx);

%%% transpose if necessary
if size(val.uqang, 2) > size(val.uqang, 1);     val.uqang = val.uqang'; end

if sum(pk <= uqang) > 4
    val.uqang = [val.uqang(1)-22.5; val.uqang];
    val.mn = [val.mn(end); val.mn];
    val.sd = [val.sd(end); val.sd];
elseif sum(pk <= uqang) < 4
    val.uqang = [val.uqang; val.uqang(end)+22.5];
    val.mn = [val.mn; val.mn(1)];
    val.sd = [val.sd; val.sd(1)];
end


%%% fit data to gauss
if nargin == 3
    x0 = [pk 90 max(val.mn)-min(val.mn) 0];
else
    x0 = [hnfit.mean hnfit.sd hnfit.amp hnfit.base];       
end

fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower', [pk-90 0 0 0], 'Upper',[pk+90  180 (5*max(val.mn)) min(val.mn)],...
               'StartPoint', x0); 
ft = fittype(@(mu, sig, a, b, x) gaussian(mu, sig, a, b, x), 'options', fo);
          

if size(val.uqang,2) > 1; val.uqang = val.uqang'; end

% fit and assign parameters
[fit_,gof2] = fit(val.uqang, val.mn, ft);
fitpar.mu = fit_.mu;        fitpar.sig = fit_.sig;
fitpar.a = fit_.a;          fitpar.b = fit_.b;
r2 = gof2.rsquare;


% shift if the preferred orientation is outside 0-180 window
if fitpar.mu > 180
    fitpar.mu = fitpar.mu -180;
    val.uqang = val.uqang-180;
elseif  fitpar.mu < 0
    fitpar.mu = fitpar.mu +180;
    val.uqang = val.uqang+180;
end

end

