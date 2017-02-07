function expInfo_out = getUnitComp(spec, expInfo)
% when there are is a comparison inside a unit this functions looks
% to assign the data correctly


if strcmp(spec.stimx, 'all stimuli cond') && ~(strcmp(spec.stimy, spec.stimx))
    ix = findCorrespStimIdx(spec.stimy, spec.eyex, expInfo, 0);
    iy = findCorrespStimIdx(spec.stimy, spec.eyey, expInfo, 1);
elseif strcmp(spec.stimy, 'all stimuli cond') && ~(strcmp(spec.stimy, spec.stimx))
    ix = findCorrespStimIdx(spec.stimx, spec.eyex, expInfo, 1);
    iy = findCorrespStimIdx(spec.stimx, spec.eyey, expInfo, 0);
else
    ix = findCorrespStimIdx(spec.stimx, spec.eyex, expInfo);
    iy = findCorrespStimIdx(spec.stimy, spec.eyey, expInfo);
end

if all(ix == iy)
    
    expInfo_out = singleUnitsOnly(expInfo(ix | iy));

else 
    error('the indices are not matching. check the stimulus condition');
end


end



function ind = findCorrespStimIdx(specstim, speceye, expInfo, neg_flag)

if nargin < 4
    neg_flag = false;
end

switch speceye
    case 'all'
        eye_spec = zeros(1, length(expInfo));
        for idi = unique([expInfo.idi]);
            
            idx = find([expInfo.idi] == idi);
            [~, maxi] =  max( cellfun(@max, {expInfo(idx).ratemn} ) );
            
            if ~isempty(idx)
                eye_spec(idx(maxi)) = 1;
            end
        end
        
    case 'dominant eye'
        eye_spec = [expInfo.isdominant];
    case 'non-dominant eye'
        eye_spec = ~[expInfo.isdominant] & [expInfo.ocul]~=0;
end

if neg_flag
    if strcmp(specstim , 'RC')
        ind = ~[expInfo.isRC] & eye_spec;
    elseif strcmp(specstim , 'adapt')
        ind = ~[expInfo.isadapt] & eye_spec;
    else
        ind = ~strcmp({expInfo.param1}, specstim) & eye_spec ...
            & ~[expInfo.isadapt] & ~[expInfo.isRC]; 
    end
else
    if strcmp(specstim , 'all stimuli cond')
        ind = eye_spec;
    elseif strcmp(specstim , 'RC')
        ind = [expInfo.isRC];
    elseif strcmp(specstim , 'adapt')
        ind = [expInfo.isadapt] & eye_spec;
    else
        ind = strcmp({expInfo.param1}, specstim) & eye_spec ...
            & ~[expInfo.isadapt] & ~[expInfo.isRC]; 
    end
end



end


function retinfo = findCorrespDat(datinfo)
%%% if there are multiple data for one neuron, take the one with the best r2



if isempty(datinfo)
    retinfo = datinfo;
elseif length(datinfo) > 1
    [~, i] = max([datinfo.rsqr_drug]);
    retinfo = datinfo(i);
else
    retinfo = datinfo;
end


end




function expInfo_out = singleUnitsOnly(exinfo)
% if there are conflicting data from the same session, the one with highest
% baseline response is used


idx_5HT1 = singleUnitsOnlyHelper(exinfo, [exinfo.is5HT]& [exinfo.isc2]);
idx_5HT2 = singleUnitsOnlyHelper(exinfo, [exinfo.is5HT]& ~[exinfo.isc2]);

idx_NaCl1 = singleUnitsOnlyHelper(exinfo, ~[exinfo.is5HT]& [exinfo.isc2]);
idx_NaCl2 = singleUnitsOnlyHelper(exinfo, ~[exinfo.is5HT]& ~[exinfo.isc2]);

expInfo_out = exinfo([idx_5HT1; idx_5HT2; idx_NaCl1; idx_NaCl2]);
    

end


function idx_su = singleUnitsOnlyHelper(exinfo, id_5HT)

idx_su = [];
id_i = unique([exinfo(id_5HT).id]);
for i = 1:length(id_i)
    
    idx_temp = find([exinfo.id] == id_i(i) & id_5HT); % indices of current unit
    
    if length(idx_temp) > 1
        [~,k] = max(cellfun(@max, {exinfo(idx_temp).ratemn}));
        idx_su = [idx_su; idx_temp(k)];
    else
        idx_su = [idx_su; idx_temp];
    end
end

end