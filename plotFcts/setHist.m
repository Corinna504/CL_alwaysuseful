function setHist(ax, lim_, varargin)
% set the histogram for paper plotting

ylim_h = 50;
arrowpos = [0 0];
fsz = 8; msz = 2; txtsz = 5; 
transpy = 0.6;
j=1;
while j <= length(varargin)
    switch varargin{j}
        case 'ylim_h'
            ylim_h = varargin{j+1};
        case 'arrow'
            arrowpos = varargin{j+1};
        case 'fsz'
            fsz = varargin{j+1};
        case 'txtsz'
            txtsz = varargin{j+1};
        case 'sz'
            sz = varargin{j+1};
        case 'alpha'
            transpy = varargin{j+1};
        case 'msz'
            msz = varargin{j+1};
    end
    j = j+2;
end

PosterProps(ax, lim_, [0 ylim_h], varargin{:}); 

ax.YTick = ylim_h;
ax.YTickLabel = ax.YTickLabel(2);
ax.XTick = [];
ax.FontSize = fsz;
delete(ax.Children(1));
delete(ax.Children(2));
ax.Children(1).XData = arrowpos(1);
ax.Children(1).YData = ax.YTick;
ax.Children(1).Color = 'r';
ax.Children(1).MarkerFaceColor = 'r';
ax.Children(1).MarkerSize = msz;

ax.Children(2).XData = arrowpos(2);
ax.Children(2).YData = ax.YTick;
ax.Children(2).MarkerSize = msz;
ax.Title.String = '';

if ax.View(1) == 90
    ax.Children(1).Marker = '<';
    ax.Children(2).Marker = '<';
end

% adjust bin edges and width
if ~strcmp(ax.Children(3).BinWidth, 'nonuniform')
    if ax.Children(3).BinWidth < ax.Children(4).BinWidth
        ax.Children(4).BinWidth = ax.Children(3).BinWidth;
    else
        ax.Children(3).BinWidth = ax.Children(4).BinWidth;
    end
end

% set transparancy
ax.Children(3).FaceAlpha = transpy; ax.Children(4).FaceAlpha = transpy;


% add statistic mean/geometric mean/median as text
text(ax, arrowpos(1)-(ax.XLim(2)*0.01), ax.YTick+(ax.YTick*0.1), num2str(arrowpos(1)), ...
    'FontSize', txtsz);
text(ax, arrowpos(2)+(ax.XLim(2)*0.1), ax.YTick+(ax.YTick*0.1), num2str(arrowpos(2)),...
    'FontSize', txtsz);

ax.LineWidth = 0.5;
% axis off;
end
