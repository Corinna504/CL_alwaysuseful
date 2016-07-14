function [ marker ] = markerAssignment( exinfo )

marker = '^';

switch exinfo.param1
    case 'or'
        marker = 'o';
    case 'sf'
        marker = 's';
    case 'co'
        marker = 'd';
    case 'sz'
        marker = 'p';
end


end

