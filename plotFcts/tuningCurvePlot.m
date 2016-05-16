function h = tuningCurvePlot(exinfo, fit_flag)
% plots tuning curve for both conditions +/- sme
% if fit_flag is true, the gauss fitted tuning curve is shown 

h = figure('Name', exinfo.figname);

if fit_flag
    fittedTC(exinfo)
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



%%
function fittedTC(exinfo)
% plots fitted tuning curve for both conditions +/- sme
   


c = getCol(exinfo);
ft = exinfo.fitparam;
ft_drug = exinfo.fitparam_drug;

args = {'o', 'Color', c, 'MarkerSize', 5};
fittedTC_Helper(ft,  [args, 'MarkerFaceColor', c], {c}); ho;
fittedTC_Helper(ft_drug,  args, {c, 'LineStyle', '--'});


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


title( sprintf( ['Baseline: pf=%1.2f, bw=%1.2f, amp=%1.2f, off=%1.2f \n' ...
    exinfo.drugname ': pf=%1.2f, bw=%1.2f, amp=%1.2f, off=%1.2f \n'], ...
    ft.mu, ft.sig, ft.a, ft.b, ...
    ft_drug.mu, ft_drug.sig, ft_drug.a, ft_drug.b) );




end


function fittedTC_Helper(ft, errArgs, lineArgs)


or = ft.mu-100 : ft.mu+100;
y = gaussian(ft.mu, ft.sig, ft.a, ft.b, or) ;

errorbar(ft.val.uqang, ft.val.mn, ft.val.sd, errArgs{:}); ho
plot(or, y, lineArgs{:}); ho

end


