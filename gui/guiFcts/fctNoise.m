function dat  = fctNoise(ex, rate_flag)
%rNoise_z
% returns z-normed spike rates grouped for each stimuli condition pair 
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
    
    for j = 1:length(e2_vals)
        ind2 = e2_vals(j) == [ex.Trials.(ex.exp.e2.type)];
        
        dat.leg{j} = num2str(e2_vals(j));
        dat.me(j) = e2_vals(j);
        dat.znorm{i,j} = zscore([ex.Trials(ind1&ind2).(fname)])';
        
    end
end


dat.znorm = cell2mat(dat.znorm);
end
