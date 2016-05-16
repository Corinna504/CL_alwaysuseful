function [ marker ] = markerAssignment( input )

marker = '^';

switch input
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

