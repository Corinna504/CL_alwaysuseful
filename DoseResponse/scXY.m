function scXY( dat, xname, yname )
% plots x and y for dat


%     plot([dat(ind1).(xname)], [dat(ind1).(yname)], 'r-'); hold on;
ind = find([dat.is5HT]);

step = (max([dat.(xname)]) - min([dat.(xname)])) / 10;

for i = ind
    scatter([dat(i).(xname)], [dat(i).(yname)], ...
        10*[dat(i).dose], 'r', ...
        'ButtonDownFcn', {@GuiPlotTC, dat, i}); hold on;
    
    scatter([dat(i).(xname)]-step, [dat(i-1).(yname)], 80, ...
        'r', 'filled', 'MarkerFaceAlpha', 0.5, ...
        'ButtonDownFcn', {@GuiPlotTC, dat, i}); hold on;
end


if strcmp(yname, 'relauc') || strcmp(yname, 'gslope')
    set(gca, 'YScale', 'log');
end

title('baseline: filled, 5HT:emtpy');
xlabel(xname); ylabel(yname);

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
    
    
    exp1 = find([dat.unit]==dat(i).unit & [dat.isc1] == dat(i).isc1 &...
        [dat.isRC] == dat(i).isRC & strcmp({dat.stim}, dat(i).stim) &  ...
        [dat.numinexp]==1, 1, 'first');
    
    PlotTC( dat(exp1).fdir, dat(exp1).fname, 'plot', true );
    h2 = gcf;
    ax2 = gca;
    set(ax2.Children, 'Color', 'r');
    copyobj(ax2.Children, ax);
    close(h2);
    
    
end
