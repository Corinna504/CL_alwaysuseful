function h = tuningCurvePlot(exinfo, fit_flag)
% plots tuning curve for both conditions +/- sme
% if fit_flag is true, the gauss fitted tuning curve is shown 

h = figure('Name', exinfo.figname);

if strcmp(exinfo.param1, 'or')
    if isfield(exinfo.fitparam, 'others')
        fittedTC_orco(exinfo)
    else
        fittedTC_or(exinfo)
    end
elseif strcmp(exinfo.param1, 'co')
    fittedTC_co(exinfo)
else
    rawTC(exinfo);
end

savefig(h, exinfo.fig_tc);
close(h);

end




%%
function rawTC(exinfo)
% plots tuning curve for both conditions +/- sme

c = getCol(exinfo);

mn0 = exinfo.ratemn;        mn1 = exinfo.ratemn_drug;
sme0 = exinfo.ratesme;      sme1 = exinfo.ratesme_drug;   
par0 = exinfo.ratepar;      par1 = exinfo.ratepar_drug;

% plot errorbars
errorbar(1:length(par0), mn0, sme0, 'Color', c); hold on;
errorbar(1:length(par1), mn1, sme1, 'LineStyle', ':' , 'Color', c);
legend('base', exinfo.drugname);

% emphasize blanks
iblank0 = find(par0 > 1000);
plot(iblank0, mn0(iblank0), 'go');
iblank1 = find(par1 > 100);
plot(iblank1, mn1(iblank1), 'go');


%     set(gca, 'XTickLabelRotation', 45, 'FontSize', 8);
parvalab = cellstr(num2str(par0'));
set(gca, 'XTick', 1:length(par0), 'XTickLabel', parvalab);
xlim([0, length(parvalab)+1]); xlabel(exinfo.param1), ylabel('spks/s (\pm sme)');
axis square; box off;

end

%% orientation contrast RC

function fittedTC_orco(exinfo)

n = ceil(length(exinfo.fitparam.others.OR)/2)+1;
for i = 1:length(exinfo.fitparam.others.OR)
    
    subplot( n , 2, i)
    exinfo_temp = exinfo;
    exinfo_temp.fitparam  = exinfo.fitparam.others.OR(i);    
    exinfo_temp.fitparam_drug  = exinfo.fitparam_drug.others.OR(i);
    fittedTC_or(exinfo_temp); xlabel(''); ylabel('');
    ylabel(['co = ' num2str(exinfo.sdfs.y(1,i))]);
end

% difference
s_diff = subplot( n, 2, 6);
[~, idx] = sort(exinfo.sdfs.y(1,:));
surf(exinfo.sdfs.x(:,1), exinfo.sdfs.y(1,idx), ...
    exinfo.sdfs.mn_rate(1).mn(:, idx)'- exinfo.sdfs_drug.mn_rate(1).mn(:, idx)'); ho
title('Difference (Base-Drug)');ylabel('co'); xlabel('or'); zlabel('spk/frame');

caxis([min(min([exinfo.ratemn,exinfo.ratemn_drug])) , ...
    max(max([exinfo.ratemn,exinfo.ratemn_drug]))])
colormap jet;
set(s_diff, 'YScale', 'log')



minc = min(min([exinfo.sdfs.mn_rate(1).mn; exinfo.sdfs_drug.mn_rate(1).mn]));
maxc = max(max([exinfo.sdfs.mn_rate(1).mn; exinfo.sdfs_drug.mn_rate(1).mn]));


% Baseline
s(1) = subplot( n, 2, 7);
[~, idx] = sort(exinfo.sdfs.y(1,:));
surf(exinfo.sdfs.x(:,1), exinfo.sdfs.y(1,idx), exinfo.sdfs.mn_rate(1).mn(:, idx)'); ho
title('Baseline');ylabel('co'); xlabel('or'); zlabel('spk/frame');
caxis([minc maxc]);


% 5HT/NaCl
s(2) = subplot( n, 2, 8);
[~, idx] = sort(exinfo.sdfs_drug.y(1,:));
surf(exinfo.sdfs_drug.x(:,1), exinfo.sdfs_drug.y(1,idx),exinfo.sdfs_drug.mn_rate(1).mn(:, idx)');
title(exinfo.drugname); ylabel('co'); xlabel('or'); zlabel('spk/frame');
caxis([minc maxc]);


set(s, 'YScale', 'log', 'ZLim', ...
    [min([s(1).ZLim(1), s(2).ZLim(1)]),  max([s(1).ZLim(2), s(2).ZLim(2)])], ...
    'XLim', [0 180], 'YLim', [min(exinfo.sdfs_drug.y(1,:)) max(exinfo.sdfs_drug.y(1,:))]);


set(findobj('Type', 'Axes'), 'FontSize', 6)
set(gcf, 'Position', [1229         206         436         763]);
end

%% orientation data
function fittedTC_or(exinfo)
% plots fitted tuning curve for both conditions +/- sme
   

c = getCol(exinfo);
ft = exinfo.fitparam;
ft_drug = exinfo.fitparam_drug;

args = {'o', 'Color', c, 'MarkerSize', 5};
fittedTC_or_Helper(ft,  [args, 'MarkerFaceColor', c], {c}); ho;
fittedTC_or_Helper(ft_drug,  args, {c, 'LineStyle', '--'});


xlabel('orientation'); 

if exinfo.isRC
    ylabel('spks/frame (\pm sme)');
else
    ylabel('spks/s (\pm sme)');
end

axis square; box off;
axchild = get(gca, 'Children');


temp = [];
for i = 1:length(axchild) 
    temp = [temp, axchild(i).XData];
end

xlim([min(temp)-5 max(temp)+5]);


title( sprintf( ['B: pf=%1.0f, bw=%1.0f, amp=%1.1f, off=%1.1f \n' ...
    exinfo.drugname ': pf=%1.0f, bw=%1.0f, amp=%1.1f, off=%1.1f \n'], ...
    ft.mu, ft.sig, ft.a, ft.b, ...
    ft_drug.mu, ft_drug.sig, ft_drug.a, ft_drug.b), 'FontSize', 8);




end


function fittedTC_or_Helper(ft, errArgs, lineArgs)

or = ft.mu-100 : ft.mu+100;
y = gaussian(ft.mu, ft.sig, ft.a, ft.b, or) ;

errorbar(ft.val.uqang, ft.val.mn, ft.val.sd, errArgs{:}); ho
plot(or, y, lineArgs{:}); ho

end


%% contrast data
function fittedTC_co(exinfo)
% plots tuning curve for both conditions +/- sme

c = getCol(exinfo);

mn0 = exinfo.ratemn;            mn1 = exinfo.ratemn_drug;
sme0 = exinfo.ratesme;          sme1 = exinfo.ratesme_drug;   
par0 = exinfo.ratepar;          par1 = exinfo.ratepar_drug;
par0(par0==0) = par0(2)/2;      par1(par1==0) = par1(2)/2;
idx0 = par0<=1;                 idx1 = par1<=1;

errArgs = {'o', 'Color', c, 'MarkerSize', 5};

% plot errorbars
fittedTC_co_Helper(exinfo.fitparam, {c})
fittedTC_co_Helper(exinfo.fitparam_drug, {c, 'LineStyle', '--'})

errorbar(par0(idx0), mn0(idx0), sme0(idx0), errArgs{:}, 'MarkerFaceColor', c); hold on;
errorbar(par1(idx1), mn1(idx1), sme1(idx1), errArgs{:});
if any(idx0); errorbar(2, mn0(~idx0), sme0(~idx0), errArgs{:}); end
if any(idx1); errorbar(2, mn1(~idx1), sme1(~idx1), errArgs{:}, 'MarkerFaceColor', c); end

legend('base', exinfo.drugname, 'Location', 'northwest');
set(gca, 'XScale', 'log', 'XLim', [0.01 2]);

title( sprintf(['r_{max} * (c^n / (c^n + c50^n) ) + m \n '...
    'baseline: r_{max}=%1.0f, n=%1.1f, c50=%1.1f, m=%1.1f r2=%1.2f \n' ...
    '   ' exinfo.drugname ': r_{max}=%1.0f, n=%1.1f, c50=%1.1f, m=%1.1f r2=%1.2f  \n' ....
    'a_{cog} = %1.1f (%1.2f)  a_{actg} = %1.1f (%1.2f)  a_{resg} = %1.1f (%1.2f) '],...
    exinfo.fitparam.rmax, ...
    exinfo.fitparam.n, exinfo.fitparam.c50, ...
    exinfo.fitparam.m, exinfo.fitparam.r2, ...
    exinfo.fitparam_drug.rmax, ...
    exinfo.fitparam_drug.n, exinfo.fitparam_drug.c50, ...
    exinfo.fitparam_drug.m, exinfo.fitparam_drug.r2, ...
    exinfo.fitparam_drug.a_cg, exinfo.fitparam_drug.r2_cg, ...
    exinfo.fitparam_drug.a_ag, exinfo.fitparam_drug.r2_ag, ...
    exinfo.fitparam_drug.a_rg, exinfo.fitparam_drug.r2_rg), ...
    'FontSize', 7);
xlabel('contrast (log)');
ylabel('spike rate');

end

function fittedTC_co_Helper(ft, lineArgs)

co = 0.001:0.001:1;
y = hyperratiofct(co, ft.rmax, ft.c50, ft.n, ft.m) ;

plot(co, y, lineArgs{:}); ho

end