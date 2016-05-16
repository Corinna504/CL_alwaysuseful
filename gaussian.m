
function y = gaussian(mu, sig, a, b, x)
% simple gaussian equation with four parameters 
    
y  = a*exp( - ((x-mu).^2 / (2*sig.^2)) ) + b;

end



