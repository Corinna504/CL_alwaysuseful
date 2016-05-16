function info = getValidField( info )

%---------------------------------------------- choose one trial per neuron
valid  = zeros(1, length(info));
intracmp = zeros(1, length(info));
for neuron = unique([info.id])
    
    neuron_idx = [info.id] == neuron ...
        & ~[info.isadapt];
    
    or_idx = find(strcmp({info.param1}, 'or') & neuron_idx & ~[info.isRC]);
    rc_idx = find(strcmp({info.param1}, 'or') & neuron_idx & [info.isRC]);
    sf_idx = find(strcmp({info.param1}, 'sf') & neuron_idx);
    co_idx = find(strcmp({info.param1}, 'co') & neuron_idx);
    sz_idx = find(strcmp({info.param1}, 'sz') & neuron_idx);
    
    %%%
    if any(or_idx)
        [~, i] = max([info(or_idx).rsqr_both]);
        valid(or_idx(i)) = 1;
        
        [~, i] = max(cellfun(@max, {info(or_idx).ratemn}));
        intracmp(or_idx(i)) = 1;
    end
    
    %%%
    if any(rc_idx)
        [~, i] = max([info(rc_idx).rsqr_both]);
        valid(rc_idx(i)) = 1;
        
        [~, i] = max(cellfun(@max, {info(rc_idx).ratemn}));
        intracmp(rc_idx(i)) = 1;
    end
    
    %%%
    if any(sf_idx)
        [~, i] = max([info(sf_idx).rsqr_both]);
        valid(sf_idx(i)) = 1;
        
        [~, i] = max(cellfun(@max, {info(sf_idx).ratemn}));
        intracmp(sf_idx(i)) = 1;
    end
    
    %%%
    if any(co_idx)
        [~, i] = max([info(co_idx).rsqr_both]);
        valid(co_idx(i)) = 1;
        
        [~, i] = max(cellfun(@max, {info(co_idx).ratemn}));
        intracmp(co_idx(i)) = 1;
    end
    
    %%%
    if any(sz_idx)
        [~, i] = max([info(sz_idx).rsqr_both]);
        valid(sz_idx(i)) = 1;
        
        [~, i] = max(cellfun(@max, {info(sz_idx).ratemn}));
        intracmp(sz_idx(i)) = 1;
    end
    
    
end

intracmp        = num2cell(intracmp);
[info.cmpExp] = deal(intracmp{:});

valid        = num2cell(valid==1);
[info.valid] = deal(valid{:});


end

