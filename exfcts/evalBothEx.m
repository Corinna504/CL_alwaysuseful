function exinfo = evalBothEx(ex0, ex2, exinfo, p_flag)
%evalBothEx evaluates operations on both base (ex0) and drug (ex2) files



%% preferred/unpreferred stimuli occuring in both files

idx = ismember(exinfo.ratepar, exinfo.ratepar_drug) &  exinfo.ratepar<1000;
parb = exinfo.ratemn;       

parb(~idx, :) = 0;
[~, exinfo.pfi] = max( parb );
exinfo.pfi_drug = find(exinfo.ratepar_drug == exinfo.ratepar( exinfo.pfi ));

parb(~idx) = 10^4;
[~, exinfo.upfi] = min( parb );
exinfo.upfi_drug = find(exinfo.ratepar_drug == exinfo.ratepar( exinfo.upfi ));


% pupil size
% [exinfo.ppsz_mu, exinfo.ppsz_mu_drug, ppsz_h] = ...
%     ppsz_mu(ex0.Trials, ex2.Trials, exinfo.drugname, p_flag);
% 
% if p_flag
%     figure(ppsz_h(1)); title(strrep(exinfo.figname, '_', ' '));
%     if strcmp(exinfo.drugname, 'NaCl');
%         set(findobj(ppsz_h(1), 'Color', 'r'), 'Color', 'k');
%     end
%     set(ppsz_h, 'tag', 'ppsz');
% end



%% gain change
[exinfo.gslope, ...
    exinfo.yoff, ...
    exinfo.r2reg] = ...
    type2reg(exinfo, p_flag);

%% fitting parameters
if isfield(exinfo.fitparam, 'others')
    
    %%% orientation
    for i = 1:length(exinfo.fitparam.others.OR)

        cont = exinfo.fitparam.others.OR(i).val.mn;
        cont = [cont; exinfo.ratemn(exinfo.ratepar>180)];
        drug = exinfo.fitparam_drug.others.OR(i).val.mn;
        drug = [drug; exinfo.ratemn_drug(exinfo.ratepar_drug>180)];
        [beta0, beta1, xvar] = ...
            perpendicularfit(cont, drug, var(drug)/var(cont));       
        
        exinfo.fitparam.others.OR(i).yoff = beta0;
        exinfo.fitparam.others.OR(i).gslope = beta1;
        exinfo.fitparam.others.OR(i).r2reg = xvar;
    end
    
    %%% contrast
    cont = exinfo.fitparam.others.CO.val;
    drug = exinfo.fitparam_drug.others.CO.val;
    
    [beta0, beta1, xvar] = ...
        perpendicularfit(cont, drug, var(drug)/var(cont));
    
    exinfo.fitparam.others.CO.yoff = beta0;
    exinfo.fitparam.others.CO.gslope = beta1;
    exinfo.fitparam.others.CO.r2reg = xvar;
        
end


%% wave form
if isfield(ex0.Trials, 'Waves') && isfield(ex2.Trials, 'Waves')
    ind0 = ~cellfun(@isempty, {ex0.Trials.Waves});
    ind2 = ~cellfun(@isempty, {ex2.Trials.Waves});
    exinfo.wdt = waveWidth( exinfo, vertcat(ex0.Trials(ind0).Waves),...
        vertcat(ex2.Trials(ind2).Waves), p_flag );
    
end


%% pfreferred orientation fit evaluation

if strcmp(exinfo.param1, 'or');
    if isfield(exinfo.fitparam, 'OR')
        
        for i = 1:length(exinfo.fitparam.OR)
            
            if abs(exinfo.fitparam.OR(i).mu - exinfo.fitparam_drug.OR(i).mu) > 150
                if exinfo.fitparam.OR(i).mu < exinfo.fitparam_drug.OR(i).mu
                    exinfo.fitparam.OR(i).mu = exinfo.fitparam.OR(i).mu +180;
                elseif exinfo.fitparam_drug.OR(i).mu < exinfo.fitparam.OR(i).mu
                    exinfo.fitparam_drug.OR(i).mu = exinfo.fitparam_drug.OR(i).mu +180;
                end
            end
        end
        
    else
        
        if abs(exinfo.fitparam.mu - exinfo.fitparam_drug.mu) > 150
            if exinfo.fitparam.mu < exinfo.fitparam_drug.mu
                exinfo.fitparam.mu = exinfo.fitparam.mu +180;
            elseif exinfo.fitparam_drug.mu < exinfo.fitparam.mu
                exinfo.fitparam_drug.mu = exinfo.fitparam_drug.mu +180;
            end
        end
    end
end
end




