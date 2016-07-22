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
        [~, i] = max([info(or_idx).r2reg]);
        valid(or_idx(i)) = 1;
    end
    
    %%%
    if any(rc_idx)
        [~, i] = max([info(rc_idx).r2reg]);
        valid(rc_idx(i)) = 1;
    end
    
    %%%
    if any(sf_idx)
        [~, i] = max([info(sf_idx).r2reg]);
        valid(sf_idx(i)) = 1;
    end
    
    %%%
    if any(co_idx)
        [~, i] = max([info(co_idx).r2reg]);
        valid(co_idx(i)) = 1;
    end
    
    %%%
    if any(sz_idx)
        [~, i] = max([info(sz_idx).r2reg]);
        valid(sz_idx(i)) = 1;
    end
    
    
end


valid        = num2cell(valid==1);
[info.valid] = deal(valid{:});


end

