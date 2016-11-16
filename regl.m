function  regl()
% plots a regression line in the plot for all data plotted with scatter



% if there is user data, take only Serotonin d
if isempty(get(gca, 'UserData'))
    obj = gca;
    
    sc = findobj(obj, 'type', 'scatter');
    col = vertcat(sc.MarkerFaceColor);
    
    ind = col(:,1) ==1 & col(:,2) == 0 & col(:,3) == 0;
    
    if any(ind)
        xdat = horzcat(sc(ind).XData);
        ydat = horzcat(sc(ind).YData);
    else
        xdat = horzcat(sc.XData);
        ydat = horzcat(sc.YData);
    end
else
    dat = get(gca', 'UserData');
    xdat = dat.x(dat.is5HT);
    ydat = dat.y(dat.is5HT);
end



% fit and plot according to axis scale
if strcmp(get(gca, 'XScale'), 'log')
    hold on
%     mdl =fitlm(log(xdat), ydat);
%     plot(get(gca, 'xlim'), log(get(gca, 'xlim')).*mdl.Coefficients.Estimate(2) + ...
%         mdl.Coefficients.Estimate(1), 'b--', 'LineWidth', 2); hold on;

    
    [beta0, beta1] = fit_bothsubj2error(log(xdat), ydat, var(ydat)/var(log(xdat))); ho;
    plot(get(gca, 'xlim'), log(get(gca, 'xlim')).*beta1 +beta0, 'k--', 'LineWidth', 2);
   
else
    nani=isnan(xdat)|isnan(ydat); 
    [beta0, beta1] = fit_bothsubj2error(xdat(~nani), ydat(~nani), var(ydat(~nani))/var(xdat(~nani))); ho; 
    plot(get(gca, 'xlim'), get(gca, 'xlim').*beta1 +beta0, 'k--', 'LineWidth', 2)
end


end

