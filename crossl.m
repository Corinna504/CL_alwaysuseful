function crossl 

hold on;
xlim_ = get(gca, 'xlim');
ylim_ = get(gca, 'ylim');

if strcmp(get(gca, 'xscale'), 'log')
    plot([1 1], ylim_, 'k--');
else
    plot([0 0], ylim_, 'k--');
end


if strcmp(get(gca, 'yscale'), 'log')
    plot(xlim_, [1 1], 'k--');
else
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

