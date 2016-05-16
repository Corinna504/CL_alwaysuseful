function h = rcPlot( exinfo )
%specified plotting of sdfs when generatign expInfo
%
%make two subplots for each baseline and drug condition
%
% @CL 22.01.2016

c = hsv(length(exinfo.sdfs.s));
h = figure('Name', exinfo.figname, 'UserData', exinfo, 'Position', [ 680   274   560   704]);
g = [0.9 0.9 0.9];
%------------------------------------------ baseline
s1 = subplot(3,1,1);

% responses
for i = 1:length(exinfo.sdfs.s)
   plot(exinfo.times/10, exinfo.sdfs.s{i}, 'Color', c(i,:)); ho 
end
if ~isempty(exinfo.sdfs.extras)
    plot(exinfo.times/10, exinfo.sdfs.extras{1}.sdf, 'r:'); ho 
end

set(gca, 'ylim', [0, max( [ max(sqrt(exinfo.resvars)*4) max(vertcat(exinfo.sdfs.s{:})) ]) ]);
ylim_ = get(s1, 'ylim');

% window for noise calculation
fill([exinfo.times(201)/10,  exinfo.times(201)/10, ...
    exinfo.times(400)/10, exinfo.times(400)/10] , ...
    [0 ylim_(2)/10 ylim_(2)/10 0], g, 'EdgeColor', g); ho



% legend and axes specification
for i = 1:length(exinfo.sdfs.n)
    leg{i} = sprintf('%1.0f \t n=%1.0f', exinfo.sdfs.x(i), exinfo.sdfs.n(i)); 
end

if ~isempty(exinfo.sdfs.extras)
    leg{length(exinfo.sdfs.n)+1} = sprintf('blank \t n=%1.0f', exinfo.sdfs.extras{1}.n); 
end

legend(leg, 'Location', 'EastOutside');
xlim([0 160]);
s = horzcat(exinfo.sdfs.s{:});
meanfr = mean(mean(s(201:400, :),2));
title(sprintf('base lat: %1.1f, dur: %1.1f, \n average sd: %1.2f, mean fr: %1.2f',...
    exinfo.lat, exinfo.dur, mean(sqrt(exinfo.resvars(201:400))), meanfr));


%------------------------------------------- drug
s2 = subplot(3,1,2);

% responses
for i = 1:length(exinfo.sdfs_drug.s)
   plot(exinfo.times/10, exinfo.sdfs_drug.s{i}, 'Color', c(i,:)); ho 
end
if ~isempty(exinfo.sdfs_drug.extras)
    plot(exinfo.times/10, exinfo.sdfs_drug.extras{1}.sdf, 'r:'); ho 
end

% window for noise calculation
fill([exinfo.times_drug(201)/10,  exinfo.times_drug(201)/10, ...
    exinfo.times_drug(400)/10, exinfo.times_drug(400)/10 ], ...
    [0 ylim_(2)/10 ylim_(2)/10 0], g, 'EdgeColor', g); 


% legend, title and axis specifications
for i = 1:length(exinfo.sdfs_drug.n)
    leg{i} = sprintf('%1.0f \t n=%1.0f', exinfo.sdfs_drug.x(i), exinfo.sdfs_drug.n(i)); 
end
if ~isempty(exinfo.sdfs_drug.extras)
    leg{length(exinfo.sdfs_drug.n)+1} = sprintf('blank \t n=%1.0f', exinfo.sdfs_drug.extras{1}.n); 
end

legend(leg, 'Location', 'EastOutside');
xlim([0 160]); xlabel('time in ms after stimulus onset');

s_drug = horzcat(exinfo.sdfs_drug.s{:});
meanfr_drug = mean(mean(s_drug(201:400, :),2));

title(sprintf('drug lat: %1.1f, dur: %1.1f, \n average sd: %1.2f, meanfr: %1.2f',...
    exinfo.lat_drug, exinfo.dur_drug, mean(sqrt(exinfo.resvars_drug(201:400))), meanfr_drug));


%--------------------------------- equalize y axis and plot latency line\

ylim_ = [0, max([max(get(s1, 'ylim')), max(get(s2, 'ylim'))])]; 
set(s1, 'ylim', ylim_); % equalize y axis
set(s2, 'ylim', ylim_); % equalize y axis

plot(s1, [exinfo.lat exinfo.lat], ylim_, 'k');
plot(s2, [exinfo.lat_drug exinfo.lat_drug], ylim_, 'k');

plot(s1, [exinfo.lat+exinfo.dur, exinfo.lat+exinfo.dur], ylim_, 'k');
plot(s2, [exinfo.lat_drug+exinfo.dur_drug, exinfo.lat_drug+exinfo.dur_drug], ylim_, 'k');


%--------------------------------- third plot showing normalized sdf dev

s3 = subplot(3,1,3);

% amplified deviation to mean response
c = getCol(exinfo);
plot(exinfo.times/10, sqrt(exinfo.resvars)./ max(sqrt(exinfo.resvars)), ...
    c, 'LineWidth', 1.5); hold on;
plot(exinfo.times_drug/10, sqrt(exinfo.resvars_drug)./ max(sqrt(exinfo.resvars_drug)), ...
    c, 'LineStyle', '--', 'LineWidth', 1.5); 

legend('base', exinfo.drugname);


%--------------------------------- save
savefig(h, exinfo.fig_sdfs);
close(h);

end
