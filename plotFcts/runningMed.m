function [mn, err, center] = runningMed(X, Y)
% computes the running mean (former median)

col =  [176 224 230] ./255; % color

nelements = floor(length(X)/20);

inan = isnan(X) | isnan(Y);
X = X(~inan); Y = Y(~inan);

[X, isort]=sort(X);
Y = Y(isort);

n = floor(length(X)/nelements);
idx = floor(linspace(1,length(X),n)); 
for i = 2:n
    mn(i-1) = nanmean(Y(idx(i-1):idx(i)-1));
    err(i-1) = nanstd(Y(idx(i-1):idx(i)-1));% / length(idx(i-1):idx(i)-1);
    center(i-1) = median(X([idx(i-1),idx(i)-1]));
end

mn(n) = Y(end);
err(n) = 0; %err = err.*2;
center(n) = X(end);
hold on
% plot(center, mn, 'kx-', 'LineWidth', 1 );  hold on;

center = [center(1) center center(end)];
err = [err(1) err err(end)];
mn = [mn(1) mn mn(end)];
fill([center fliplr(center)],  [mn+err fliplr(mn-err)], col, 'EdgeColor', col);

ax = gca;
uistack(ax.Children(1), 'bottom');



% 
% nbin = 2;   N = inf;
% while max(N) > length(X)/10 && nbin <30
%     nbin = nbin+1;
%     [N, edges] = histcounts(X, nbin);
% end
% 
% 
% for e = 2:length(edges)
%    x_patch(e-1) = edges(e);
%     
%    x(e-1) = mean([edges(e-1), edges(e)]);
%    y(e-1)= nanmean(Y (X>=edges(e-1) & X<=edges(e)));
%    err(e-1)= nanstd(Y (X>=edges(e-1) & X<=edges(e))) / sqrt(sum(X>=edges(e-1) & X<=edges(e)));
% end
% 
% idx_y = ~isnan(y);
% y = y(idx_y);
% err = err(idx_y);
% x = x(idx_y);
% 
% plot(x, y, 'kx-', 'LineWidth', 1 );  hold on;
% 
% y = [y(1) y y(end)];
% err = [err(1) err err(end)];
% x = [edges(1) x edges(end)];
% fill([x fliplr(x)],  [y+err fliplr(y-err)], 'k', ...
%     'FaceAlpha', 0.1, 'EdgeAlpha', 0.2);
% 
% 
% crossl;
end
