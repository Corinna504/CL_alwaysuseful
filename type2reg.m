function [beta1, beta0, xvarX, xvarY, xvarXY]  = type2reg(exinfo, p_flag)
% type2reg returns the offset and slope for the best fit linear regression
% that is subject to both errors (x and y).



% % only take those conditions that are present in both experiments
s1 = exinfo.ratepar;  %or/sf/co/... values used in the experiment
s2 = exinfo.ratepar_drug;

cont = exinfo.ratemn( ismember( s1, s2 ) );
drug = exinfo.ratemn_drug( ismember( s2, s1 ) );


% calculate perpendicular distance minimizing fit
[beta0, beta1, xvarX, xvarY, xvarXY] = perpendicularfit(cont, drug, var(drug)/var(cont));


% triangular fit
% [Lt, beta1, xvarXY] = trianglefit(x, y) ;
% beta0 = mean(y)-m*mean(x);

if p_flag
    
    h = figure('Name', exinfo.figname);
    scatter(cont, drug, 100, getCol(exinfo), 'filled',...
        'MarkerFaceAlpha', 0.5); hold on;
    

    if any(s1)>1000 && any(s2)>1000
        scatter(cont(end), drug(end), 100, 'g', 'filled',...
            'MarkerFaceAlpha', 0.5); hold on;
    end
    
    eqax;
    xlim_ = get(gca, 'xlim');
    plot(xlim_, xlim_.*beta1 + beta0, getCol(exinfo), 'LineWidth', 2); hold on;

    xlabel('baseline');
    ylabel(exinfo.drugname);
    
    title(sprintf( 'gain = %1.2f, add = %1.2f, \n r2_{x}=%1.2f  r2_{y}=%1.2f r2_{xy}=%1.2f', ...
        beta1, beta0, xvarX, xvarY, xvarXY));
    unity; axis square; box off;
    
    ylim_ = get(gca, 'YLim');
    hold on
    plot([mean(cont) mean(cont)], ylim_, 'Color', [0.5 0.5 0.5 0.5])
    plot(xlim_, [mean(drug) mean(drug)], 'Color', [0.5 0.5 0.5 0.5])
    
    savefig(h, exinfo.fig_regl);
    close(h);
end


if isnan(xvarX) 
    xvarX = 0;    xvarY = 0;    xvarXY = 0;
    beta0 = -inf; beta1 = 0;
end

end





function [Lt, m, expvar] = trianglefit(x, y)
% triangular area calculation after Barker et al 1980

% center data around 0 ( easier calculation )
x2 = x - mean(x);
y2 = y - mean(y);

% estimated b1 via triangle minimization
m = sign(sum( y2.*x2 )) * sqrt( sum( y2.^2 ) / sum( x2.^2 ) );


ssx = sum( x2.^2 );
ssy = sum( y2.^2 );

% area of triangles
Lt = - sign(sum( x2.* y2 )) * sum( x2.* y2 ) + sqrt(ssx.*ssy);

expvar = 1-(Lt / sqrt(ssx*ssy));

end
