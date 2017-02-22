function [h]=plot3d_errorbars(x, y, z, e, varargin)
% this matlab function plots 3d data using the plot3 function
% it adds vertical errorbars to each point symmetric around z
% I experimented a little with creating the standard horizontal hash
% tops the error bars in a 2d plot, but it creates a mess when you 
% rotate the plot
%
% x = xaxis, y = yaxis, z = zaxis, e = error value

% create the standard 3d scatterplot
h=plot3(x, y, z, varargin{:});

% looks better with large points
set(h, 'MarkerSize', 25);
hold on

% now draw the vertical errorbar for each point

for i=1:size(x,1)
    for j = 1:size(x,2)
        xV = [x(i, j); x(i,j)];
        yV = [y(i,j); y(i,j)];
        zMin = z(i,j) + e(i,j);
        zMax = z(i,j) - e(i,j);

        zV = [zMin, zMax];
        % draw vertical error bar
        h=plot3(xV, yV, zV, '-');
        set(h, 'LineWidth', 2);
    end
end