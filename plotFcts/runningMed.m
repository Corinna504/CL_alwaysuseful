function [x, y, edges] = runningMed(X, Y)
% computes the running mean (former median)



nbin = 2;   N = inf;
while max(N) > length(X)/10 && nbin <30
    nbin = nbin+1;
    [N, edges] = histcounts(X, nbin);
end


for e = 2:length(edges)
   x_patch(e-1) = edges(e);
    
   x(e-1) = mean([edges(e-1), edges(e)]);
   y(e-1)= nanmean(Y (X>=edges(e-1) & X<=edges(e)));
   err(e-1)= nanstd(Y (X>=edges(e-1) & X<=edges(e))) / sqrt(sum(X>=edges(e-1) & X<=edges(e)));
end

idx_y = ~isnan(y);
y = y(idx_y);
err = err(idx_y);
x = x(idx_y);

plot(x, y, 'kx-', 'LineWidth', 1 );  hold on;

y = [y(1) y y(end)];
err = [err(1) err err(end)];
x = [edges(1) x edges(end)];
fill([x fliplr(x)],  [y+err fliplr(y-err)], 'k', ...
    'FaceAlpha', 0.1, 'EdgeAlpha', 0.2);


crossl;
end
