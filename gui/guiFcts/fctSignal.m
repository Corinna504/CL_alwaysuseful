function dat = fctSignal(ex, rate_flag)
%rSig_mu
% groups spike rates for each condition pair and returns their arithmetic
% means
% norm_flag determines whether to use spike rate (norm_falg = 1) or spike count
% (norm_flag = 0)


fname = 'spkRate';
if nargin == 2
   if ~rate_flag ; fname = 'nSpks'; end
end

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
        dat.mu(i, j) = mean([ex.Trials(ind1&ind2).(fname)]);
        dat.var(i, j) = var([ex.Trials(ind1&ind2).(fname)]);
    
        
    end
end

end
