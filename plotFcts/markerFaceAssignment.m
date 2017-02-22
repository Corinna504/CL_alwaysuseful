function col = markerFaceAssignment( exinfo )

% if exinfo.ismango
    if exinfo.is5HT 
        col = 'r';
    elseif ~exinfo.is5HT
        col = 'k';
    end
    
%     if exinfo.electrodebroken
%         col = 'b';
%     end
% else
%     col = 'w';
%     
%     if exinfo.electrodebroken
%         col = [0,191,255]./255;
%     end
% end




end

