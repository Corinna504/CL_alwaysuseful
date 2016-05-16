function exinfo = getDominantEyeField( exinfo )

%--------------- select dominant eye
isdominant = zeros(1, length(exinfo));

for neuron = unique([exinfo.id])
    
    neuron_idx = [exinfo.id] == neuron; %& [info.rsqr4drug] >= expVarThres & ~[info.isadapt] & ~[info.isRC];
    or_idx = find(strcmp({exinfo.param1}, 'or') & neuron_idx);
    sf_idx = find(strcmp({exinfo.param1}, 'sf') & neuron_idx);
    co_idx = find(strcmp({exinfo.param1}, 'co') & neuron_idx);
    sz_idx = find(strcmp({exinfo.param1}, 'sz') & neuron_idx);
    
    
    if any(or_idx)
        nobino  = find([exinfo(or_idx).ocul] ~= 0);
        [~, uid]  = max(cellfun(@mean, {exinfo(or_idx(nobino)).ratemn}));
        if ~isempty(nobino)
            dom_i = [exinfo.ocul] == exinfo(or_idx(nobino(uid))).ocul ...
                & [exinfo.id] == neuron & strcmp({exinfo.param1}, 'or');
            isdominant(dom_i) = true;
        end
    end
    
    if any(sf_idx)
        nobino  = find([exinfo(sf_idx).ocul] ~= 0);
        [~, uid]  = max(cellfun(@mean, {exinfo(sf_idx(nobino)).ratemn}));
        if ~isempty(nobino)
            dom_i   = [exinfo.ocul] == exinfo(sf_idx(nobino(uid))).ocul ...
                & [exinfo.id] == neuron & strcmp({exinfo.param1}, 'sf');
            isdominant(dom_i) = true;
        end
    end
    
    if any(co_idx)
        nobino  = find([exinfo(co_idx).ocul] ~= 0);
        [~, uid]  = max(cellfun(@mean, {exinfo(co_idx(nobino)).ratemn}));
        if ~isempty(nobino)
            dom_i   = [exinfo.ocul] == exinfo(co_idx(nobino(uid))).ocul ...
                & [exinfo.id] == neuron & strcmp({exinfo.param1}, 'co');
            isdominant(dom_i) = true;
        end
    end
    
    
    if any(sz_idx)
        nobino  = find([exinfo(sz_idx).ocul] ~= 0);
        [~, uid]  = max(cellfun(@mean, {exinfo(sz_idx(nobino)).ratemn}));
        if ~isempty(nobino)
            dom_i   = [exinfo.ocul] == exinfo(sz_idx(nobino(uid))).ocul ...
                & [exinfo.id] == neuron & strcmp({exinfo.param1}, 'sz');
            isdominant(dom_i) = true;
        end
    end
    
    
end


isdominant  = num2cell(isdominant==1);
[exinfo.isdominant] = deal(isdominant{:});

cmpExp = num2cell(zeros(length(exinfo), 1));
[exinfo.cmpExp] = deal(cmpExp{:});

for uid = unique([exinfo.idi]);
    idx = find([exinfo.idi] == uid & [exinfo.rsqr_both]>0.5);
    [~, maxi] =  max( cellfun(@max, {exinfo(idx).ratemn} ) );
    
    if ~isempty(idx)
        exinfo(idx(maxi)).cmpExp = 1;
    end
end


end

