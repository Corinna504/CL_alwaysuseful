function expInfo = addStruct( expInfo )
% post hoc expansion of expInfo struct


for i = 1:length(expInfo)
    
    if ~isempty(expInfo(i).fitparam)
        if isfield(expInfo(i).fitparam, 'OR') 
            maxi = find( max(expInfo(i).sdfs.y(1,:)) == max(expInfo(i).sdfs.y(1,:)), 1, 'first');
            expInfo(i).gaussr2 = expInfo(i).fitparam.OR(maxi).r2; 
        else
            expInfo(i).gaussr2 = expInfo(i).fitparam.r2;
        end
    else
        expInfo(i).gaussr2 = 0;
    end
    
    if ~isempty(expInfo(i).fitparam_drug)
        if isfield(expInfo(i).fitparam_drug, 'OR')
            maxi = find( max(expInfo(i).sdfs_drug.y(1,:)) == max(expInfo(i).sdfs_drug.y(1,:)), 1, 'first');
            expInfo(i).gaussr2 = expInfo(i).fitparam_drug.OR(maxi).r2;
        else
            expInfo(i).gaussr2_drug = expInfo(i).fitparam_drug.r2;
        end
    else
        expInfo(i).gaussr2_drug = 0;
    end
    
    if isempty( expInfo(i).lat )
        expInfo(i).lat = -10;
    end
    
    if isempty( expInfo(i).lat_drug )
        expInfo(i).lat_drug = -10;
    end
    
%     if expInfo(i).id == 176 && expInfo(i).isRC
%         expInfo(i).lat = -1;
%         expInfo(i).lat_drug = -1;
%     end
%     
%     if expInfo(i).id == 182 && expInfo(i).isRC
%         expInfo(i).lat = -1;
%         expInfo(i).lat_drug = -1;
%     end
    
end


end

