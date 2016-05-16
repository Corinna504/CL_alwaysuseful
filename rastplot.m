function h = rastplot( raster, varargin ) 
%raster plot for matrix with 0s and 1s
% number of rows is time and number of columns is number of trials


h = figure;
time = 1:size(raster, 1);
psth = 0;
j = 1;

while j < length(varargin)
switch varargin{j}
    case 'time'
        time = varargin{j+1};
    case 'psth'
        psth = varargin{j+1};
end
j = j+2;
end



if psth
    subplot(2,1,1);
end

for i = 1:size(raster, 2)
   idx = find(raster(:,i));
   
    for j = idx'
        plot( [time(j)' time(j)'], [raster(j,i)+i raster(j,i)+i+1] ); ho
    end
end

set(gca, 'xlim', [time(1), time(end)], 'ylim', [1 size(raster, 2)]);


if psth
    subplot(2,1,2);
    width = 3;
    x = -0:width*3;
    kl = exp(-(x.^2)/(2 * width^2));
    ps = conv(sum(raster'),kl);
    fullsdf = [ps(1:end-3*width) .* 2 * 10000/(sqrt(2 * pi) * ...
						  width * sum(sum(raster)))];
    plot(time, fullsdf);
end
set(gca, 'xlim', [time(1), time(end)]);




end

