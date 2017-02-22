function [mn, sd] = binnedMean( x, y )
% computes the mean of binned y 


bins = sort(unique(x));
for j = 1:length(bins)
   
    idx = x==bins(j);
    mn(j) = nanmean(y(idx));
    sd(j) = nanstd(y(idx))/sum(idx);
        
end

hold on;
plot(bins, mn, 'kx-');  hold on;

fill([bins fliplr(bins)],  [mn+sd fliplr(mn-sd)], 'k', ...
    'FaceAlpha', 0.1, 'EdgeAlpha', 0.2);


end

