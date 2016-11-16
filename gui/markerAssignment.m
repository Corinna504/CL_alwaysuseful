function [ marker ] = markerAssignment( param1, monkey )

marker = '^';

if strcmp(monkey, 'ma')
    marker = 'o';
    
elseif strcmp(monkey, 'ka')
    marker = 's';
    
end


% switch param1
%     case 'or'
%         marker = 'o';
%     case 'sf'
%         marker = 's';
%     case 'co'
%         marker = 'd';
%     case 'sz'
%         marker = 'p';
% end

end

