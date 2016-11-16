function plotXYdose( dat, xname, yname )
% plots x and y for dat

figure;

for unt = unique([dat.unit])

    
    ind2 = [dat.is5HT]==1;
    
    
    plot([dat(ind1).(xname)], [dat(ind1).(yname)], 'r-'); hold on;
    
    
    ind = ind1 & ind2;
    scatter([dat(ind).(xname)], [dat(ind).(yname)], ...
        10*[dat(ind).dose], ...
        'r', 'MarkerFaceAlpha', 0.5); hold on;
    
    ind = ind1 & ~ind2;
    scatter([dat(ind).(xname)], [dat(ind).(yname)], 80, ...
        'r', 'filled', 'MarkerFaceAlpha', 0.5); hold on;
    
end


xlabel(xname); ylabel(yname);



if dat(1).relfrate ==1
    plot(get(gca, 'xlim'), [1 1], 'Color', [0.5 .5 .5])
elseif dat(1).relfrate ==0 
    plot(get(gca, 'xlim'), [0 0], 'Color', [0.5 .5 .5])
end

end

