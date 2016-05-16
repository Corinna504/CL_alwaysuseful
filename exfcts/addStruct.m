function expInfo = addStruct( expInfo )
% post hoc expansion of expInfo struct


for i = 1:length(expInfo)
    
    if ~isempty( expInfo(i).fitparam )
        expInfo(i).gaussr2 = expInfo(i).fitparam.r2;
    else
        expInfo(i).gaussr2 = 0;
    end
    
    if ~isempty( expInfo(i).fitparam_drug )
        expInfo(i).gaussr2_drug = expInfo(i).fitparam_drug.r2;
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

