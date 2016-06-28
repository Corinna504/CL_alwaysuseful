function crossl 

hold on;
ax = gca;
c = findobj(ax, 'Type', 'Scatter');
xlim_ = get(ax, 'xlim');
ylim_ = get(ax, 'ylim');

if strcmp(get(ax, 'xscale'), 'log')
    plot([1 1], ylim_, 'k--');
else
    plot([0 0], ylim_, 'k--');
end


if strcmp(get(ax, 'yscale'), 'log')
    plot(xlim_, [1 1], 'k--');
else
%     plot( [min(horzcat(c.XData)) max(horzcat(c.XData))] , [0 0], 'k--');
    plot(xlim_, [0 0], 'k--');
end


xlim(xlim_);
ylim(ylim_);

try
    ax = gca;
    for i = 1:2
        ax.Children(i).Color = [0 0 0 0.3];
        ax.Children(i).LineStyle = '-';
        ax.Children(i).LineWidth = 2;
    end
    uistack(ax.Children(1:2), 'bottom');
catch
    warning('was not able to push unity line to bottom');
end
end

