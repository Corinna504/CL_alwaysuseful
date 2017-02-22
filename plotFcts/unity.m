function u = unity()
% plots a unity line in the current axis

hold on;
xlim_ = get(gca, 'XLim');
ylim_ = get(gca, 'YLim');


if strcmp(get(gca, 'XScale'), 'log') && strcmp(get(gca, 'YScale'), 'log')
    if xlim_(1) == 0
        ch = get(gca, 'Children');
        minx = min(horzcat(ch.XData));
        if minx == 0
            xlim_(1) = 1/100;
        else 
            xlim_(1) = minx;
        end
    end
    u = plot(xlim_', xlim_', '--k');
elseif strcmp(get(gca, 'XScale'), 'log')
    u = plot(xlim_, xlim_, '--c');
elseif strcmp(get(gca, 'YScale'), 'log')
    u = plot(ylim_, ylim_, '--k');
else
    u = plot(xlim_, xlim_, '--k');
end

try
    ax = gca;
    ax.Children(1).Color = [0 0 0 0.4];
    ax.Children(1).LineStyle = '-';
    ax.Children(1).LineWidth = 0.5;
    uistack(ax.Children(1), 'bottom');
catch
    warning('was not able to push unity line to bottom');
end

hold off;
end