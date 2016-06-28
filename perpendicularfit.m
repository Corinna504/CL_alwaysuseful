function [beta0, beta1, xvarX, xvarY, xvarXY] = perpendicularfit(x, y, alpha)
% calls fit_bothsubj2error and calculates the explained variance

SSTy = sum( (y-mean(y)).^2 );
SSTx = sum( (x-mean(x)).^2 );

% fit that considers both x and y as subject to error
[beta0, beta1] = fit_bothsubj2error(x, y, alpha);

% predicted values by fit
xfit = (y - beta0) / beta1;
yfit = x * beta1 + beta0;

% residual sum of squares
SSRx = sum( (x - xfit).^2 );
SSRy = sum( (y - yfit).^2 );

% explained variance
xvarX = 1 - (SSRx / SSTx);
xvarY = 1 - (SSRy / SSTy);

% distance between predicted and true data points
h_fit = getTriangleHeight((x-xfit).^2, (y-yfit).^2);
SSP_fit = sum( h_fit );

h_tot = getTriangleHeight((x-mean(x)).^2, (y-mean(y)).^2); 
SSP_tot = sum( h_tot );


xvarXY = 1- (SSP_fit / SSP_tot);



if xvarY < 0; xvarY = 0; end
if xvarX < 0; xvarX = 0; end
if xvarXY < 0; xvarXY = 0; end

end







function hc = getTriangleHeight(a, b)
% because we are in a right triangle, we can take the short version

a2 = a.^2;    b2 = b.^2;    
hc = sqrt( a2+b2 ); 
% hc = (a.*b)./c;
% hc( c==0 ) = 0;

end