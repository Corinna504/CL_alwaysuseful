function ploterr( dat, xname, yname, zname )
% plots x and y for dat



factorx = unique([dat.(xname)]);
factory = unique([dat.(yname)]);


if strcmp(zname, 'z')
    
    for i = 1:length(factorx)
        
        % 5HT index
        ind = find([dat.(xname)]== factorx(i)& [dat.is5HT]==1 ...
            & ~[dat.isRC] & strcmp({dat.stim}, 'co'));
        
        if any(ind)
            % 5HT responses
            mn = nanmean([dat(ind).(yname)]);
            sem = nanstd([dat(ind).(yname)]) ./ sqrt(length(ind));
            
            errorbar(i, mn, sem, 'ro'); hold on;
            
            
            % responses before 5HT application
            ind = ind-1;
            mn = nanmean([dat(ind).(yname)]);
            sem = nanstd([dat(ind).(yname)]) ./ sqrt(length(ind));
            
            errorbar(i-0.5, mn, sem, 'ro', 'MarkerFaceColor', 'r'); hold on;
        end
    end
    
    if dat(1).(yname) ==1
        set(gca, 'YScale', 'log')
    end
    title('filled: baseline/recovery, empty: 5HT');
    
    
else
    
    mn = nan(length(factorx), length(factory));
    for i = 2:2:length(factorx)
        for j = 1:length(factory)
            % 5HT index
            ind = find([dat.(xname)]== factorx(i)& ...
                [dat.(yname)]== factory(j) & ...
                [dat.is5HT]==1 & ~[dat.isRC] & strcmp({dat.stim}, 'co'));
            if any(ind)
                % 5HT responses
                mn(i, j) = nanmean([dat(ind).(zname)]);
                sem(i, j) = nanstd([dat(ind).(zname)]) ./ sqrt(length(ind));
                
                % responses before 5HT application
                ind = ind-1;
                mn(i-1, j) = nanmean([dat(ind).(zname)]);
                sem(i-1, j) = nanstd([dat(ind).(zname)]) ./ sqrt(length(ind));
            end
        end
    end
    
    mesh(factorx, factory, mn'); 
    
    
    if dat(1).(zname) ==1
        set(gca, 'ZScale', 'log')
    end
end


xlabel(xname); ylabel(yname);
set(gca, 'XTick', 1:length(factorx), 'XTickLabel', cellstr(num2str(factorx')));

crossl;
box off;

end

