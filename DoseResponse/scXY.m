function scXY( dat, xname, yname, zname )
% plots x and y for dat


ind = find([dat.is5HT]);
stepx = (max([dat.(xname)]) - min([dat.(xname)])) / 10;
stepy = (max([dat.(yname)]) - min([dat.(yname)])) / 10;


if strcmp(zname, 'z')
    for i = ind
        scatter([dat(i).(xname)], [dat(i).(yname)], ...
            10*[dat(i).dose], 'r', ...
            'ButtonDownFcn', {@GuiPlotTC, dat, i}); hold on;
        
        scatter([dat(i).(xname)]-stepx, [dat(i-1).(yname)], 80, ...
            'r', 'filled', 'MarkerFaceAlpha', 0.5, ...
            'ButtonDownFcn', {@GuiPlotTC, dat, i}); hold on;
    end
    title('baseline: filled, 5HT:emtpy');

else
    for i = ind
        scatter3([dat(i).(xname)], [dat(i).(yname)], [dat(i).(zname)],...
            50, 'r', 'filled','MarkerFaceAlpha', 0.5,...
            'ButtonDownFcn', {@GuiPlotTC, dat, i}); hold on;
        
        scatter3([dat(i).(xname)]-stepx, [dat(i).(yname)]-stepy, [dat(i-1).(zname)],...
            50, 'b', 'filled', 'MarkerFaceAlpha', 0.5, ...
            'ButtonDownFcn', {@GuiPlotTC, dat, i}); hold on;
    end
    title('baseline: blue, 5HT: red');
    
end


if strcmp(yname, 'relauc') || strcmp(yname, 'gslope')
    set(gca, 'YScale', 'log');
end

if strcmp(zname, 'relauc') || strcmp(zname, 'gslope')
    set(gca, 'ZScale', 'log');
    zlabel(zname);
    grid on;
    zlim([min([dat.(zname)]) max([dat.(zname)])]);
end


xlabel(xname); ylabel(yname);
xlim([min([dat.(xname)]) max([dat.(xname)])]);
ylim([min([dat.(yname)]) max([dat.(yname)])]);



end



function GuiPlotTC(~, ~, dat, i)

PlotTC( dat(i).fdir, dat(i).fname, 'plot', true );
ax = gca;
hold on;
PlotTC( dat(i-1).fdir, dat(i-1).fname, 'plot', true );
h2 = gcf;
ax2 = gca;

copyobj(ax2.Children, ax);
close(h2);


% exp1 = find([dat.unit]==dat(i).unit & [dat.isc1] == dat(i).isc1 &...
%     [dat.isRC] == dat(i).isRC & strcmp({dat.stim}, dat(i).stim) &  ...
%     [dat.numinexp]==1, 1, 'first');

exp1 = find([dat.unit]==dat(i).unit & [dat.isc1] == dat(i).isc1 &  ...
    [dat.numinexp]==1, 1, 'first');

PlotTC( dat(exp1).fdir, dat(exp1).fname, 'plot', true );
h2 = gcf;
ax2 = gca;
set(ax2.Children, 'Color', 'r');
copyobj(ax2.Children, ax);
close(h2);


end
