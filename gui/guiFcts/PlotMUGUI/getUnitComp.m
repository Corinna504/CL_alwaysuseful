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

% expInfo_out = singleUnitsOnly(expInfo(ix | iy));
expInfo_out = expInfo(ix & iy);
end



function ind = findCorrespStimIdx(specstim, speceye, expInfo, neg_flag)

if nargin < 4
    neg_flag = false;
end

switch speceye
    case 'all'
        eye_spec = zeros(1, length(expInfo));
        
        for uid = unique([expInfo.idi]);
            
            idx = find([expInfo.idi] == uid);
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




function expInfo_out = singleUnitsOnly(expInfo)
% if there are conflicting data from the same session, the one with best
% regression fit is used

    idi = unique([expInfo.idi]);
    idxsu = [];
    for i = 1:length(idi) 
       
        if sum([expInfo.idi] == idi(i)) > 1
        
            idx_idi = find([expInfo.id] == idi(i));
            [~,k] = max([expInfo(idx_idi).r2reg]);
            idxsu = [idxsu; idx_idi(k)];
        else
            idxsu = [idxsu; find([expInfo.id] == idi(i))];
        
        end
    end

    expInfo_out = expInfo(idxsu);
    

end
