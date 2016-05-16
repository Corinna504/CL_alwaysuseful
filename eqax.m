function eqax( )


xlim_ = get(gca, 'xlim');
ylim_ = get(gca, 'ylim');



try
    objs = findobj(gca, 'Type', 'Scatter');
    minx = min(horzcat(objs.XData));
    maxx = max(horzcat(objs.XData));
    
    miny = min(horzcat(objs.YData));
    maxy = max(horzcat(objs.YData));
    
    set(gca, 'xlim', [ min(minx, miny) max(maxx, maxy) ], ...
        'ylim', [ min(minx, miny) max(maxx, maxy) ]);
    
catch
    
    minx = min(xlim_);
    maxx = max(xlim_);
    
    miny = min(ylim_);
    maxy = max(ylim_);
    
    set(gca, 'xlim', [ min(minx, miny) max(maxx, maxy) ], ...
        'ylim', [ min(minx, miny) max(maxx, maxy) ]);
end

    
    
    
    
    
    
end

