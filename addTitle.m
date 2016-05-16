function addTitle( i_drug, dat )

if any(i_drug) && any(~i_drug)
    
    xdat1 = dat.x(i_drug)';     ydat1 = dat.y(i_drug)';
    
    mnx1 = mean(xdat1);         mny1 = mean(ydat1);
    medx1 = median(xdat1);         medy1 = median(ydat1);
    
    xdat2 = dat.x(~i_drug)';    ydat2 = dat.y(~i_drug)';
    
    mnx2 = mean(xdat2);         mny2 = mean(ydat2);
    medx2 = median(xdat2);         medy2 = median(ydat2);
    
    
    
    if strfind(dat.xlab, 'gain')
        xdat = log(dat.x(i_drug));  
    elseif strfind(dat.ylab, 'gain')
        ydat = log(dat.y(i_drug));
    end
    
    
    [rho, p] = corr(xdat1, ydat1);
    [rhos, ps] = corr(xdat1, ydat1, 'type', 'Spearman');
    
    [rho2, p2] = corr(xdat2, ydat2);
    [rhos2, ps2] = corr(xdat2, ydat2, 'type', 'Spearman');
    
    [~, pttest] = ttest(xdat1, ydat1);
    psign = signrank(xdat1, ydat1);
      
    title(sprintf(['5HT(n=%1.0f) \t r_{p}=%1.2f p=%1.3f \t r_{s}=%1.2f p=%1.3f   \\mu_x = %1.2f \\mu_y = %1.2f   med_x = %1.2f med_y = %1.2f \n '...
        'NaCl(n=%1.0f) \t r_{p}=%1.2f p=%1.3f \t r_{s}=%1.2f p=%1.3f \\mu_x = %1.2f \\mu_y = %1.2f   med_x = %1.2f med_y = %1.2f\n'...
        'paired ttest p=%1.3f, signrank test p=%1.3f' ],...
        length(xdat1),rho, p, rhos, ps, mnx1, mny1, medx1, medy1, ...
        length(xdat2), rho2, p2, rhos2, ps2,  mnx2, mny2, medx2, medy2, ...
        pttest, psign), 'FontSize', 8, 'FontWeight', 'bold');
    
    
elseif any(i_drug) || any(~i_drug)
    [rho, p1] = corr(dat.x', dat.y');
    [rhos, ps1] = corr(dat.x', dat.y', 'type', 'Spearman');
    
    
    [~, p2] = ttest(dat.x', dat.y');
    p_wil = ranksum(dat.x', dat.y');
    
    title(sprintf(['n = %1.0f \t r_{p} =%1.2f p=%1.3f r_{s} =%1.2f p=%1.3f \n'...
        '\t paired-t p=%1.3f \t wilk p=%1.3f'] ,...
        [length(dat.x), rho, p1, rhos, ps1, p2, p_wil]), 'FontSize', 8, 'FontWeight', 'bold');
end

end

