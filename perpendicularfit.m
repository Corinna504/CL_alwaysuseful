function [beta0, beta1, xvar] = perpendicularfit(x, y, alpha)
% calls fit_bothsubj2error and calculates the explained variance

SSTy = sum( (y-mean(y)).^2 );

% fit that considers both x and y as subject to error
[beta0, beta1] = fit_bothsubj2error(x, y, alpha);

% predicted values by fit
yfit = x * beta1 + beta0;

% residual sum of squares
SSRy = sum( (y - yfit).^2 );
% explained variance
xvar = 1 - (SSRy / SSTy);
if xvar < 0; xvar = 0; end

end
