for kk = 1:length(exinfo)
   
    
   if ~exinfo(kk).isRC 
    exinfo(kk).ff.classic.ff = ( exinfo(kk).ff.classic.spkcnt_var ./ exinfo(kk).ff.classic.spkcnt_mn );
    exinfo(kk).ff_drug.classic.ff = ( exinfo(kk).ff_drug.classic.spkcnt_var ./ exinfo(kk).ff_drug.classic.spkcnt_mn ); 
   end

end

%%
clc
length(unique([exinfo(cellfun(@(x) strcmp(x, 'or'), {exinfo.param1}) & ...
    ~[exinfo.isRC] & [exinfo.is5HT] & ...    
    [exinfo.p_anova]<0.05 &[exinfo.p_anova_drug]<0.05 & ...    
    cellfun(@(x) min(x)>3, {exinfo.nrep}) & cellfun(@(x) min(x)>3, {exinfo.nrep_drug}) & ...
    ~[exinfo.isc2] & ...    
    cellfun(@(x) max(x)>=10, {exinfo.ratemn}) & ...
    cellfun(@(x) isnan(x) || x<150, {exinfo.resistance})).id]))

dat = exinfo(cellfun(@(x) strcmp(x, 'or'), {exinfo.param1}) & ...
    ~[exinfo.isRC] & [exinfo.is5HT] & ...    
    [exinfo.p_anova]<0.05 &[exinfo.p_anova_drug]<0.05 & ...    
    cellfun(@(x) min(x)>3, {exinfo.nrep}) & cellfun(@(x) min(x)>3, {exinfo.nrep_drug}) & ...
    ~[exinfo.isc2] & ...    
    cellfun(@(x) max(x)>=10, {exinfo.ratemn}) & ...
    cellfun(@(x) isnan(x) || x<150, {exinfo.resistance}));

%% nonparamatric change
for kk = 1:length(exinfo)
   
    
    
   % check whether electrodes were broken
    exinfo(kk).electrodebroken = ismember(exinfo(kk).id, broken_id);
    
    % check whether electrodes were broken and excluded    
    if exinfo(kk).is5HT
        exinfo(kk).electrodebroken_excl = ismember(exinfo(kk).id, broken_excl_5HT);
        exinfo(kk).electrodebroken_incl_underrest = ismember(exinfo(kk).id, broken_incl_5HT_rest);
    else
        exinfo(kk).electrodebroken_excl = ismember(exinfo(kk).id, broken_excl_nacl);
        exinfo(kk).electrodebroken_incl_underrest = 0;
    end
end


%% concatenate ex files
% exinfo_new = rcdatka04;
fnames = fieldnames(exinfo);
curlen = length(exinfo); %current length
for i = 1:length(exinfo_new)
    
   for j = 1:length(fnames)
      
       if isfield(exinfo_new, fnames{j})
           exinfo(curlen+i).(fnames{j}) = exinfo_new(i).(fnames{j});
       else
           fnames{j}
           exinfo(curlen+i).(fnames{j}) = nan;
       end
       
   end
    
end




%%

for kk = 1:length(exinfo)
    if ~exinfo(kk).isRC
        tuningCurvePlot(exinfo(kk));
    end
end


%%
for i = 1:length(exinfo_sz);

openfig(strrep(exinfo_sz(i).fig_tc, '..', '.'));
dat = get(gcf, 'UserData');
fnames = fieldnames(dat);
    
for j = 1:length(fnames)
    if isfield(exinfo_sz, fnames{j})
        exinfo_sz(i).(fnames{j}) = dat.(fnames{j});
    end
end
   

close gcf;
disp(num2str(i));
end


%%
fitparam = dat.fitparam;
idx_nonblank = [ex.Trials.(dat.param1)] ~= ex.exp.e1.blank & ...
            [ex.Trials.(dat.param1)] ~= 0;


i_cosmc50 = [ex.Trials.(dat.param1)]<=fitparam.c50 & idx_nonblank;
anova1([ex.Trials(i_cosmc50).spkRate],...
    [ex.Trials(i_cosmc50).(dat.param1)],'off')

i_cohic50 = [ex.Trials.(dat.param1)]>fitparam.c50 & idx_nonblank;
fitparam.higherc50 = anova1([ex.Trials(i_cohic50).spkRate], ...
    [ex.Trials(i_cohic50).(dat.param1)],'off')
