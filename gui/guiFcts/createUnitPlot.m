function dat = createUnitPlot(expInfo, fctX, fctY, spec, fig2plot, hist_flag)



% get Data per Unit
[ix, iy] = getUnitComp(spec, expInfo);


% if the 
if all(ix==iy)
    val = evalMU(fctX, fctY, expInfo(ix&iy));
    dat.x = val.x;
    dat.y = val.y;
else
    val = evalMU(fctX, fctY, expInfo(ix|iy));
    dat.x = val.x(ix);
    dat.y = val.y(iy);
end
dat.xlab = [val.xlab ' '  spec.stimx ' ' spec.eyex];
dat.ylab = [val.ylab ' ' spec.stimy ' ' spec.eyey];
dat.expInfo = val.exinfo;

clearvars val



% remove nan values
isntnan = find(~isnan(dat.x) & ~isnan(dat.y));
dat.x       = dat.x(isntnan);            
dat.y      = dat.y(isntnan);
dat.is5HT   = [dat.expInfo(isntnan).is5HT];  
dat.expInfo  = dat.expInfo(isntnan);  
dat.is5HT  = logical(dat.is5HT);

% edit marker
markerface = zeros(length(dat.x), 3);
markerface(find(dat.is5HT), 1) =  1;



temp = [];
for lll = 1:length(dat.x)
    
%     dat_new.expinf{lll}(1).fname
    temp(lll,1) = dat.expInfo(lll).id;
    temp(lll,2) = dat.x(lll);
    temp(lll,3) = dat.y(lll);
    temp(lll,4) = dat.expInfo(lll).isc2;

end

disp('id x y');
temp
%%%----------------------------------------------------
if hist_flag
    pos_hist = [ [0.45 .7 .28 .15];
        [0.78 .18 .12 .45];
        [0.45 .18 .28 .45] ];
else
    pos_hist(3,:)  = [0.45 .18 .5 .7];
end

%%% dinstinguish two distributions via logical indexing
i_drug = logical(markerface(:,1));
rx1 = min(dat.x) - abs(min(dat.x)/2);               rx2 = max(dat.x) + abs(max(dat.x)/2);
ry1 = min(dat.y(1, :)) - abs(min(dat.y(1,:))/2);    ry2 = max(dat.y(1, :)) + abs(max(dat.y(1, :))/2);

if hist_flag
    %%%-------------------------------- histogram x
    subplot(3,3, [1 2]);
    plotHist(dat.x, i_drug);
    set(gca, 'Position', pos_hist(1,:));
    if (rx1 - rx2) ~= 0
        set(gca, 'Xlim', [rx1 rx2])%, 'xticklabel',[]);
    end
    %%%--------------------------------- histogram y
    subplot(3,3, [6 9])
    plotHist(dat.y, i_drug);
    set(gca, 'Position', pos_hist(2, :));
    if (ry1 - ry2) ~= 0
        set(gca, 'Xlim', [ry1 ry2])  %, 'xticklabel',[]);
    end
    set(gca, 'view',[90 -90]);
    tt = findobj(gca, 'Type', 'text');
    set(tt, 'rotation', -90);
    %%%----------------------------------- main plot
    subplot(3,3, [4 5 7 8])
end

for i = 1:length(dat.x)
        scatter(dat.x(i), dat.y(i), 50, ...
            markerAssignment(dat.expInfo(i).param1, dat.expInfo(i).monkey ),...
            'MarkerFaceColor', markerFaceAssignment( dat.expInfo(i) ),...
            'MarkerEdgeColor', markerface(i,:), ...
            'MarkerFaceAlpha', 0.4,...
            'ButtonDownFcn', { @DataPressed, dat.expInfo(i), ...
            dat.xlab, dat.ylab, fig2plot} );

    hold on;
end


xlabel(dat.xlab); ylabel(dat.ylab);
hold off;
set(gca, 'Position', pos_hist(3,:), 'UserData', dat);
if (rx1 - rx2) ~= 0
    set(gca, 'xlim',  [rx1 rx2], 'ylim', [ry1 ry2]);
end

if ~hist_flag
    addTitle(i_drug, dat);
end

end


