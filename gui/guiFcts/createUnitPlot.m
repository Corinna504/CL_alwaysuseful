function dat_new = createUnitPlot(expInfo, dat_in, spec, fig2plot, hist_flag)

guiprop = PlotProps();
markerfacecol = guiprop.markerfacecol;


% get Data per Unit
dat_new = getUnitComp(dat_in, spec, expInfo);

% remove nan values
isntnan = find(~cellfun(@isempty, dat_new.expinf) & ~isnan(dat_new.x) & ~isnan(dat_new.x));
dat_new.x       = dat_new.x(isntnan);            dat_new.y      = dat_new.y(isntnan);
dat_new.indX    = dat_new.indX(isntnan);         dat_new.indY   = dat_new.indY(isntnan);
dat_new.is5HT   = dat_new.is5HT(isntnan);        dat_new.is5HT  = logical(dat_new.is5HT);
dat_new.expinf  = dat_new.expinf(isntnan);

% edit marker
markerface = zeros(length(dat_new.x), 3);
markerface(find(dat_new.is5HT), 1) =  1;



temp = [];
for lll = 1:length(dat_new.x)
    
    dat_new.expinf{lll}(1).fname
    temp(lll,1) = dat_new.expinf{lll}(1).id;
    temp(lll,2) = dat_new.x(lll);
    temp(lll,3) = dat_new.y(lll);
    
end

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
rx1 = min(dat_new.x) - abs(min(dat_new.x)/2);               rx2 = max(dat_new.x) + abs(max(dat_new.x)/2);
ry1 = min(dat_new.y(1, :)) - abs(min(dat_new.y(1,:))/2);    ry2 = max(dat_new.y(1, :)) + abs(max(dat_new.y(1, :))/2);

if hist_flag
    %%%-------------------------------- histogram x
    subplot(3,3, [1 2]);
    plotHist(dat_new.x, i_drug);
    set(gca, 'Position', pos_hist(1,:));
    if (rx1 - rx2) ~= 0
        set(gca, 'Xlim', [rx1 rx2])%, 'xticklabel',[]);
    end
    %%%--------------------------------- histogram y
    subplot(3,3, [6 9])
    plotHist(dat_new.y, i_drug);
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

for i = 1:length(dat_new.x)
    if ~isempty(dat_new.expinf{i})
        scatter(dat_new.x(i), dat_new.y(i), ...
            markerAssignment(dat_new.expinf{i}(1).param1),...
            'MarkerFaceColor', markerface(i,:), ...
            'MarkerEdgeColor',  markerface(i,:),...
            'ButtonDownFcn', { @DataPressed, dat_new.expinf{i}, ...
            dat_new.xlab, dat_new.ylab, fig2plot} );
        hold on;
        disp([dat_new.expinf{i}.id]);
    end
end


xlabel(dat_new.xlab); ylabel(dat_new.ylab);
hold off;
set(gca, 'Position', pos_hist(3,:), 'UserData', dat_new);
if (rx1 - rx2) ~= 0
    set(gca, 'xlim',  [rx1 rx2], 'ylim', [ry1 ry2]);
end


if ~hist_flag
    addTitle(i_drug, dat_new);
end

end


