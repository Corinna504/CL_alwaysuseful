function exinfo = evalBothEx(ex0, ex2, exinfo, p_flag)
%evalBothEx evaluates operations on both base (ex0) and drug (ex2) files



%% preferred/unpreferred stimuli occuring in both files

idx = ismember(exinfo.ratepar, exinfo.ratepar_drug) &  exinfo.ratepar<1000;
parb = exinfo.ratemn;       

parb(~idx) = 0;
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
    exinfo.rsqr_cont, ...
    exinfo.rsqr_drug, ...
    exinfo.rsqr_both] = ...
    type2reg(exinfo, p_flag);


%% wave form
if isfield(ex0.Trials, 'Waves') && isfield(ex2.Trials, 'Waves')
    ind0 = ~cellfun(@isempty, {ex0.Trials.Waves});
    ind2 = ~cellfun(@isempty, {ex2.Trials.Waves});
    exinfo.wdt = waveWidth( exinfo, vertcat(ex0.Trials(ind0).Waves),...
        vertcat(ex2.Trials(ind2).Waves), p_flag );
    
end



%% plot results
if ~exinfo.isRC
    exinfo.isi_frct = getISI_All(exinfo, ex0, ex2, p_flag);
    
    if p_flag
%         lfpPlot( exinfo );
        rasterPlot( exinfo, ex0, ex2);
        tuningCurvePlot(exinfo, strcmp(exinfo.param1, 'or'));        
        
%         spectogramPlot( exinfo );
    end
    
elseif exinfo.isRC && p_flag
    rcPlot(exinfo);
    tuningCurvePlot(exinfo, true);  
end



end




