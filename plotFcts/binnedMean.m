function [mn, sd] = binnedMean( x, y )
% computes the mean of binned y 

inan = isnan(x) | isnan(y);
y = y(~inan);
x = x(~inan);

bins = sort(unique(x));
for j = 1:length(bins)
   
    idx = x==bins(j);
    mn(j) = nanmean(y(idx));
    err(j) = nanstd(y(idx))/sum(idx);
%     mn(j) = prctile(y(idx), 50);
%     err(:,j) = prctile(y(idx), [25 75]);
        
end


% err = 2.*err;

hold on;
% plot(bins, mn, 'kx-');  hold on;
% 
% % fill([bins fliplr(bins)],  [err(1,:) fliplr(err(2,:))], 'k', ...
fill([bins fliplr(bins)],  [mn+err fliplr(mn-err)], [0 .4 0], ...
    'FaceAlpha', 0.1, 'EdgeAlpha', 0.2);

errorbar(bins, mn, err, 'Color', [0 .4 0], 'LineWidth', 1);

end

