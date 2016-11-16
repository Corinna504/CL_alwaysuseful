function r = GaussRatio(ks, kc, ws, wc, sz)
% ratio of gaussion to model size tuning
% sz is the stimulus diameter
% ks and kc are the gains of center and surround
% Ls and Lc are the summed squared acitivites of the center and surround
%

Lc = gaussianint(wc, sz);
Ls = gaussianint(ws, sz);

r = (kc.*Lc)./(1+(ks.*Ls));

end

function L = gaussianint(w, sz)

    fun = @(x) exp(-(x/w).^2);
    for i = 1:length(sz)
        L(i,1) = ( 2/sqrt(pi) * integral(fun, 0, sz(i)) ).^2;
    end
end