function PosterProps(ax, xlim_, ylim_, varargin)
%POSTERPROPS transforms plots to general poster style
%
%
% @author Corinna Lorenz
% @date 8.3.2015 
% PosterProps(ax, xlim, ylim)
%
% PosterProps takes the axis and x and y limits and adapts the style. In
% default, this means:
% - scatter data are increased in size to 200 (it does not need to be a
% scatter plot)
% - font size is set to 25
% - transparancy is set to 80%
% - ticks turn outside
% - axis are square
% - box is set off
% - axis tick label are beginning and end of the limit
%
%
%
%
% Using optional arguments, you can change the setting:
% - 'sz' and 'fsz' change scatter data size, respectively font size
%     PosterProps(ax, xlim, ylim, 'sz', 20)
% - 'alpha' is used to change the transperency parameter, must be [0,1]
%     PosterProps(ax, xlim, ylim, 'alpha', 0.5)
% - 'untity' adds a grey unity line and puts it in the background
%     PosterProps(ax, xlim, ylim, 'unity')
% - 'nounity' deletes preexisting, dashed lines counteracting with 'unity'
% 
% 
% 
% 
% Other setttings that can not be altered: 
% - LineWidth is set to 2.
% - Figure position is set. If you need to change it, change it outside,
% after you call PosterProps
% 
% 
% NOTE: This function was written under use of Matlab R2015a. There have
% been major changes in the plotting functions between 2014 to 2015,
% especially with the transparancy. It would recommend to use R2015a or
% later versions to work with PosterProps (also because I think plots look
% nicer with new versionse, otherwise try to make a copy and adapt it to
% older versions.
% 
% NOTE2: Put the unity function in the same folder to guarantee smooth
% collaborations.




set(gcf, 'Position', [492   269   550   500]);
axis square 
box off


fsz = 25;
sz = 200;
greyf = 0.8;
transpy = 0.5;
unity_flag = false;
cross_flag = false;
delete_unity = false;
j=1;
while j <= length(varargin)
    switch varargin{j}
        case 'sz'
            sz = varargin{j+1};
            j=j+1;
        case 'fsz'
            fsz = varargin{j+1};
            j=j+1;
        case 'unity'
            unity_flag = true;
        case 'cross'
            cross_flag = true;
        case 'alpha'
            transpy = varargin{j+1};
            j=j+1;
        case 'nounity'
            delete_unity = true;
    end
    j = j+1;
end
       


set(ax, 'xlim', [xlim_(1) xlim_(2)], ...
        'ylim', [ylim_(1) ylim_(2)], ...
        'XTick', [xlim_(1) xlim_(2)], ...
        'YTick', [ylim_(1) ylim_(2)], ...
        'TickDir', 'out', ...
        'LineWidth', 0.5, ...
        'XTickLabel', {num2str(xlim_(1)), num2str(xlim_(2)) }, ...
        'YTickLabel', {num2str(ylim_(1)), num2str(ylim_(2)) }, ...
        'Position', [0.2 0.2 0.6 0.6], 'FontSize', fsz);
%         'Position', [0.2 0.2 0.6 0.6], 'FontSize', fsz, 'FontWeight', 'bold');

set(findobj(ax, 'Type', 'Scatter'), 'SizeData', sz, 'MarkerFaceAlpha', transpy, ...
    'MarkerEdgeAlpha', transpy);
set(findobj(ax, 'Type', 'Line', 'LineStyle', 'o'), 'MarkerSize',15, ...
    'MarkerFaceAlpha', transpy, 'MarkerEdgeAlpha', transpy);
set(findobj(ax,'Type', 'Errorbar'), 'MarkerSize', 10);


if unity_flag 
    u=unity;
    u.Color = ones(1,3)*greyf;
end
if cross_flag
    c = crossl;
    set(c, 'Color', ones(1,3)*greyf);
end
   

ax.XLabel.String = '';
ax.YLabel.String = '';
ax.Layer = 'top';
ax.LineWidth = 1;

end

