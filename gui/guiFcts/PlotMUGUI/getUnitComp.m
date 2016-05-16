function dat = getUnitComp(dat, spec, expInfo)
% when there are is a comparison inside a unit this functions looks
% to assign the data correctly

xdat = dat.x;
ydat = dat.y;

dat.x = [];
dat.y = [];
id = unique([expInfo.id]);

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


%%% assign to x and y data
kk = 1;
for is5HT = 0:1
    
    condS = [expInfo.is5HT] == is5HT;
    
    for c1 = 0:1
        condc1 = [expInfo.isc2] == c1;
        
        for idx = 1:length(id)
            
            
            dat.is5HT(kk) = is5HT;
            
            id(idx)
            dat.indX{kk} = find ([expInfo.id] == id(idx) & condS & condc1 & ix);
            dat.indY{kk} = find ([expInfo.id] == id(idx) & condS & condc1 & iy);
            
            if ~isempty(dat.indX{kk}) &&  ~isempty(dat.indY{kk})
                [dat.x(kk), expInf_x] = ...
                    findCorrespDat( xdat(dat.indX{kk}), expInfo(dat.indX{kk}) );
                [dat.y(kk), expInf_y] = ...
                    findCorrespDat( ydat(dat.indY{kk}), expInfo(dat.indY{kk}) );
                dat.expinf{kk} = [expInf_x, expInf_y];
            end
            
            kk = kk+1;
            
        end
    end
end

% 
% [dat, expInfo] = singleUnitsOnly(dat, expInfo);
% 
dat.is5HT = logical(dat.is5HT);

    

end



function ind = findCorrespStimIdx(specstim, speceye, expInfo, neg_flag)

if nargin < 4
    neg_flag = false;
end

switch speceye
    case 'all'
        eye_spec = [expInfo.cmpExp];
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


function [retval, retinfo] = findCorrespDat(dat, datinfo)
%%% if there are multiple data for one neuron, take the one with the best r2



if isempty(dat)
    retval = [];
    retinfo = datinfo;
elseif length(dat) > 1
    [~, i] = max([datinfo.rsqr_drug]);
    i =1;
    retval = dat(i);
    retinfo = datinfo(i);
else
    retval = dat;
    retinfo = datinfo;
end


end




function [dat, expInfo] = singleUnitsOnly(dat, expInfo)
% if there are conflicting data from the same session, the one with best
% regression fit is used

    id = unique([expInfo.id]);
    idxsu = [];
    for i = 1:length(id) 
       
        if sum([expInfo.id] == id(i)) > 1
        
            idx_idi = find([expInfo.id] == id(i));
            [~,k] = max([expInfo(idx_idi).rsqr_both]);
            idxsu = [idxsu; idx_idi(k)];
        else
            idxsu = [idxsu; find([expInfo.id] == id(i))];
        
        end
    end

    expInfo = expInfo(idxsu);
    dat.x = dat.x(idxsu);
    dat.y = dat.y(idxsu);
    dat.expinf = dat.expinf(idxsu);
    dat.is5HT = dat.is5HT(idxsu);

end
