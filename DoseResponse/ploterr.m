function ploterr( dat, f, varargin )
% plots x and y for dat


j = 1;
depvar = 'relfrate';
while j<=length(varargin)
    switch varargin{j}
        case 'depvar'
            depvar = varargin{j+1};
    end
    j=j+1;
end


figure('Position', [1161 719    365   265]);
factorx = unique([dat.(f)]);


for i = 1:length(factorx)
   
    % 5HT responses
    ind = [dat.(f)]== factorx(i) & [dat.is5HT]==1;
    mn(i) = mean([dat(ind).(depvar)]);
    sem(i) = std([dat(ind).(depvar)]) ./ sqrt(sum(ind));
    
   errorbar(i, mn(i), sem(i), 'ro'); hold on;
   
   
   % responses before 5HT application
   ind = [ind(2:end) 0] ==1;
   mn(i) = mean([dat(ind).(depvar)]);
   sem(i) = std([dat(ind).(depvar)]) ./ sqrt(sum(ind));
    
   errorbar(i-0.5, mn(i), sem(i), 'ro', 'MarkerFaceColor', 'r'); hold on;
       
end


xlabel(f); ylabel(depvar);
set(gca, 'XTick', 1:length(factorx), 'XTickLabel', cellstr(num2str(factorx')));



if dat(1).(depvar) ==1
    set(gca, 'YScale', 'log')
end

crossl;
box off;

title('filled: baseline/recovery, empty: 5HT');

end

