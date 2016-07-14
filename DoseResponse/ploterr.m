function ploterr( dat, xname, yanem )
% plots x and y for dat



factorx = unique([dat.(xname)]);


for i = 1:length(factorx)
    
    % 5HT index
    ind = find([dat.(xname)]== factorx(i)& [dat.is5HT]==1 ...
        & ~[dat.isRC] & strcmp({dat.stim}, 'co'));
    
    if any(ind)
        % 5HT responses
        mn = nanmean([dat(ind).(yanem)]);
        sem = nanstd([dat(ind).(yanem)]) ./ sqrt(length(ind));
    
        errorbar(i, mn, sem, 'ro'); hold on;
    
        
        % responses before 5HT application
        ind = ind-1;
        mn = nanmean([dat(ind).(yanem)]);
        sem = nanstd([dat(ind).(yanem)]) ./ sqrt(length(ind));
        
        errorbar(i-0.5, mn, sem, 'ro', 'MarkerFaceColor', 'r'); hold on;
    end
end


xlabel(xname); ylabel(yanem);
set(gca, 'XTick', 1:length(factorx), 'XTickLabel', cellstr(num2str(factorx')));



if dat(1).(yanem) ==1
    set(gca, 'YScale', 'log')
end

crossl;
box off;

title('filled: baseline/recovery, empty: 5HT');

end

