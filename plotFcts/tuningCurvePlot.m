function h = tuningCurvePlot(exinfo)
% plots tuning curve for both conditions +/- sme
% if fit_flag is true, the gauss fitted tuning curve is shown 

h = figure('Name', exinfo.figname);

if strcmp(exinfo.param1, 'or') 
            fittedTC_or(exinfo)

%     if isfield(exinfo.fitparam, 'others')
%         fittedTC_orco(exinfo)
%     else
%         fittedTC_or(exinfo)
%     end
    
elseif  strcmp(exinfo.param1, 'sf')
    subplot(2,1,1)
    fittedTC_sf(exinfo, exinfo.fitparam.others{1}, exinfo.fitparam_drug.others{1});
    subplot(2,1,2)
    fittedTC_sf(exinfo, exinfo.fitparam.others{2}, exinfo.fitparam_drug.others{2});    

elseif strcmp(exinfo.param1, 'co')
    fittedTC_co(exinfo);
elseif strcmp(exinfo.param1, 'sz')
    fittedTC_sz(exinfo);
else
    rawTC(exinfo);
end

set(h, 'UserData', exinfo);
savefig(h, exinfo.fig_tc);
close(h);

end




%%
function rawTC(exinfo)
% plots tuning curve for both conditions +/- sme

c = getCol(exinfo);

mn0 = exinfo.ratemn;        mn2 = exinfo.ratemn_drug;
sme0 = exinfo.ratesme;      sme2 = exinfo.ratesme_drug;   
par0 = exinfo.ratepar;      par2 = exinfo.ratepar_drug;

% plot errorbars
errorbar(1:length(par0), mn0, sme0, 'Color', c); hold on;
errorbar(1:length(par2), mn2, sme2, 'LineStyle', ':' , 'Color', c);
legend('base', exinfo.drugname);

% emphasize blanks
iblank0 = find(par0 > 1000);
plot(iblank0, mn0(iblank0), 'go');
iblank1 = find(par2 > 100);
plot(iblank1, mn2(iblank1), 'go');


%     set(gca, 'XTickLabelRotation', 45, 'FontSize', 8);
parvalab = cellfun(@(x) sprintf('%1.1f',x), num2cell(par0),'UniformOutput' ,false);    
set(gca, 'XTick', 1:length(par0), 'XTickLabel', parvalab);
xlim([0, length(parvalab)+1]); xlabel(exinfo.param1), ylabel('spks/s (\pm sme)');
axis square; box off;

end

%% size data
function fittedTC_sz(exinfo)

c = getCol(exinfo);
val = exinfo.fitparam.val;

errorbar( val.sz,val.mn, val.sem, 'o', 'Color', c, 'MarkerFaceColor', c); ho
plot( val.x, val.y, 'Color', c);
if ~isempty(exinfo.ratepar>1000)
plot( get(gca, 'XLim'), [exinfo.ratemn(exinfo.ratepar>1000) exinfo.ratemn(exinfo.ratepar>1000)], ...
    'Color', c);
end

val = exinfo.fitparam_drug.val;
errorbar( val.sz,val.mn, val.sem, 'o', 'Color', c);
plot( val.x, val.y, 'Color', c, 'LineStyle', '--');
if ~isempty(exinfo.ratepar>1000)
plot( get(gca, 'XLim'), [exinfo.ratemn_drug(exinfo.ratepar_drug>1000) ...
    exinfo.ratemn_drug(exinfo.ratepar_drug>1000)], ...
    'Color', c, 'LineStyle', '--');
end


plot( ones(2,1)*exinfo.fitparam.mu, get(gca, 'YLim'), 'k');
plot( ones(2,1)*exinfo.fitparam_drug.mu, get(gca, 'YLim'), 'k--');

ylim_ = get(gca, 'YLim');
ylim([0 ylim_(2)]);

title(sprintf(['Base: pref sz : %1.2f, SI= %1.2f, r2=%1.2f\n' exinfo.drugname ...
    'pref sz: %1.2f, SI=%1.2f, r2=%1.2f'],...
    exinfo.fitparam.mu, exinfo.fitparam.SI, exinfo.fitparam.r2, ...
    exinfo.fitparam_drug.mu, exinfo.fitparam_drug.SI, exinfo.fitparam_drug.r2));
xlabel('size'), ylabel('spks/s');

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
colormap jet;
set(s_diff, 'YScale', 'log', ...
    'XLim', [0 180], ...
    'YLim', [min(exinfo.sdfs_drug.y(1,:)) max(exinfo.sdfs_drug.y(1,:))])
colorbar



% color axis specification
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


idx0 = exinfo.ratepar>1000;
if any(idx0); errorbar(ft.mu+120, exinfo.ratemn(idx0), exinfo.ratesme(idx0), args{:}, 'MarkerFaceColor', c); end;

idx2 = exinfo.ratepar_drug>1000;
if any(idx2); errorbar(ft.mu+120, exinfo.ratemn_drug(idx2), exinfo.ratesme_drug(idx2),args{:}); end;

axis square; box off;
axchild = get(gca, 'Children');


temp = [];
for i = 1:length(axchild) 
    temp = [temp, axchild(i).XData];
end

xlim([min(temp)-5 max(temp)+5]);


title( sprintf( ['B: pf=%1.0f, bw=%1.0f, amp=%1.1f, off=%1.1f, r2=%1.1f \n' ...
    exinfo.drugname ': pf=%1.0f, bw=%1.0f, amp=%1.1f, off=%1.1f r2=%1.1f \n'], ...
    ft.mu, ft.sig, ft.a, ft.b, ft.r2, ...
    ft_drug.mu, ft_drug.sig, ft_drug.a, ft_drug.b, ft_drug.r2), 'FontSize', 8);

end


function fittedTC_or_Helper(ft, errArgs, lineArgs)

or = ft.mu-100 : ft.mu+100;
y = gaussian(ft.mu, ft.sig, ft.a, ft.b, or) ;

errorbar(ft.val.uqang, ft.val.mn, ft.val.sd, errArgs{:}); ho
plot(or, y, lineArgs{:}); ho

end

%% spatial frequency data
function fittedTC_sf(exinfo, ft, ft_drug)
% plots fitted tuning curve for both conditions +/- sme


c = getCol(exinfo);
args = {'o', 'Color', c, 'MarkerSize', 5};
fittedTC_sf_Helper(ft,  [args, 'MarkerFaceColor', c], {c}); ho;
fittedTC_sf_Helper(ft_drug,  args, {c, 'LineStyle', '--'});

xlabel('spatial frequency');    ylabel('spks/s (\pm sme)');
axis square; box off;

xdata = [ft.val.uqang; ft_drug.val.uqang];
xlim([min(xdata)-1, max(xdata)+2]);


title( sprintf( ['B: pf=%1.0f, bw=%1.0f, amp=%1.1f, off=%1.1f r2=%1.1f\n' ...
    exinfo.drugname ': pf=%1.0f, bw=%1.0f, amp=%1.1f, off=%1.1f r2=%1.1f\n'], ...
    ft.mu, ft.sig, ft.a, ft.b, ft.r2, ...
    ft_drug.mu, ft_drug.sig, ft_drug.a, ft_drug.b, ft_drug.r2), 'FontSize', 8);

end


function fittedTC_sf_Helper(ft, errArgs, lineArgs)

sf = ft.mu-100 :0.1: ft.mu+100;
y = gaussian(ft.mu, ft.sig, ft.a, ft.b, sf) ;

errorbar(ft.val.uqang, ft.val.mn, ft.val.sd, errArgs{:}); ho
plot(sf, y, lineArgs{:}); ho

end

%% contrast data
function fittedTC_co(exinfo)
% plots tuning curve for both conditions +/- sme

c = getCol(exinfo);

mn0 = exinfo.ratemn;            mn1 = exinfo.ratemn_drug;
sme0 = exinfo.ratesme;          sme1 = exinfo.ratesme_drug;   
par0 = exinfo.ratepar;          par1 = exinfo.ratepar_drug;
errArgs = {'o', 'Color', c, 'MarkerSize', 5};


idx = par0==0;
errorbar(eps, mn0(idx), sme0(idx), errArgs{:}, 'MarkerFaceColor', c); hold on;
idx1 = par1==0;
errorbar(eps, mn1(idx1), sme1(idx1), errArgs{:});

% plot errorbars
fittedTC_co_Helper(exinfo.fitparam, {c})
fittedTC_co_Helper(exinfo.fitparam_drug, {c, 'LineStyle', '--'})

errorbar(par0, mn0, sme0, errArgs{:}, 'MarkerFaceColor', c); hold on;
errorbar(par1, mn1, sme1, errArgs{:});
legend('base', exinfo.drugname, 'Location', 'northwest');
set(gca, 'XScale','log', 'XLim', [0.005 1]);
box off;



title( sprintf(['r_{max} * (c^n / (c^n + c50^n) ) + m \n '...
    'baseline: r_{max}=%1.0f, n=%1.1f, c50=%1.1f, m=%1.1f r2=%1.2f \n' ...
    exinfo.drugname ' ind : r_{max}=%1.0f, n=%1.1f, c50=%1.1f, m=%1.1f r2=%1.2f \n' ...
    '   ' exinfo.drugname ' basepar: r_{max}=%1.0f, n=%1.1f, c50=%1.1f, m=%1.1f r2=%1.2f  \n' ....
    'a_{cog} = %1.1f (%1.2f)  a_{actg} = %1.1f (%1.2f)  a_{resg} = %1.1f (%1.2f) '],...
    exinfo.fitparam.rmax, ...
    exinfo.fitparam.n, exinfo.fitparam.c50, ...
    exinfo.fitparam.m, exinfo.fitparam.r2, ...
    exinfo.fitparam_drug.rmax, ...
    exinfo.fitparam_drug.n, exinfo.fitparam_drug.c50, ...
    exinfo.fitparam_drug.m, exinfo.fitparam_drug.r2, ...
    exinfo.fitparam_drug.rmax, ...
    exinfo.fitparam_drug.sub.n, exinfo.fitparam_drug.sub.c50, ...
    exinfo.fitparam_drug.sub.m, exinfo.fitparam_drug.sub.r2, ...
    exinfo.fitparam_drug.sub.a_cg, exinfo.fitparam_drug.sub.r2_cg, ...
    exinfo.fitparam_drug.sub.a_ag, exinfo.fitparam_drug.sub.r2_ag, ...
    exinfo.fitparam_drug.sub.a_rg, exinfo.fitparam_drug.sub.r2_rg), ...
    'FontSize', 7);
xlabel('contrast (log)');

end

function fittedTC_co_Helper(ft, lineArgs)

plot(ft.x, ft.y, lineArgs{:}); ho

end