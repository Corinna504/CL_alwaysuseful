function dat = fctTuningCurve(ex)


dat.xlab    = ex.exp.e1.type;
dat.ylab    = 'spike rate';

dat.xticklab = [cellstr(num2str(ex.exp.e1.vals')); ex.exp.e1.blankname]; 
dat.y       = [ex.Trials.spkRate];


% include blanks
e1_vals = [ex.exp.e1.vals, ex.exp.e1.blank]; %     e1_vals = ex.exp.e1.vals;
e2_vals = ex.exp.e2.vals;


% loop through all stimuli conditions and norm those grouped data
for i = 1:length(e1_vals)
    ind1 = e1_vals(i) == [ex.Trials.(ex.exp.e1.type)];
    dat.x(i) = e1_vals(i);
    
  for j = 1:length(e2_vals)
        ind2 = e2_vals(j) == [ex.Trials.(ex.exp.e2.type)];
        
        dat.leg{j} = num2str(e2_vals(j));
        dat.me(j) = e2_vals(j);
        dat.errbar{i, j} = [ex.Trials(ind1&ind2).spkRate];
        
  end
end
    
dat.x = categorical(dat.x);
dat.x = renamecats(dat.x, categories(dat.x),...
                cellstr(num2str([1:length(dat.xticklab)]')));   

%%% maybe later
% dat.Trials   = ex.Trials;          % information source for mouse hovering



end
    