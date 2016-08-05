function h = rcPlot( exinfo )
%specified plotting of sdfs when generatign expInfo
%
%make two subplots for each baseline and drug condition
%
% @CL 22.01.2016


if ~isempty(strfind(exinfo.fname, 'CO'))
    nplot = 4;
else
    nplot=3;
end


c = hsv(length(exinfo.sdfs.s));
h = figure('Name', exinfo.figname, 'UserData', exinfo, 'Position', [ 680   274   560   704]);
g = [0.9 0.9 0.9];
%------------------------------------------ baseline
s1 = subplot(nplot,1,1);
[~,co_idx]= max(exinfo.sdfs.y(1,:));

% responses
for co = 1:length(exinfo.sdfs.y(1,:))
    for i = 1:length(exinfo.sdfs.s)
        plot3( ones(length(exinfo.times),1) * exinfo.sdfs.y(1,co),...
            exinfo.times/10, exinfo.sdfs.s{i, co}, 'Color', c(i,:)); ho
    end
    if ~isempty(exinfo.sdfs.extras)
        plot3(ones(length(exinfo.times),1) * exinfo.sdfs.y(1,co),...
            exinfo.times/10, exinfo.sdfs.extras{1}.sdf, 'r:'); ho
    end
end

xlabel('co'); ylabel('time in ms after stimulus onset');

set(gca, 'zlim', ...
    [0, max( [ max(sqrt(exinfo.resvars)*4) max(vertcat(exinfo.sdfs.s{:,co_idx})) ]) ]);
ylim_ = get(s1, 'ylim');

% window for noise calculation
fill([exinfo.times(201)/10,  exinfo.times(201)/10, ...
    exinfo.times(400)/10, exinfo.times(400)/10] , ...
    [0 ylim_(2)/10 ylim_(2)/10 0], g, 'EdgeColor', g); ho



% legend and axes specification
for i = 1:size(exinfo.sdfs.n, 1)
    leg{i} = sprintf('%1.0f \t n=%1.0f', exinfo.sdfs.x(i, co_idx), exinfo.sdfs.n(i, co_idx)); 
end

if ~isempty(exinfo.sdfs.extras)
    leg{i+1} = sprintf('blank \t n=%1.0f', exinfo.sdfs.extras{1}.n); 
end

legend(leg, 'Location', 'EastOutside');
s = horzcat(exinfo.sdfs.s{:, co_idx});
meanfr = mean(mean(s(201:400),2));
title(sprintf('base lat: %1.1f, dur: %1.1f, \n average sd: %1.2f, mean fr: %1.2f',...
    exinfo.lat, exinfo.dur, mean(sqrt(exinfo.resvars(201:400, co_idx))), meanfr));
ylim([0 160]); set(gca, 'XScale', 'log');
grid on;

if nplot > 3
    xlim([min(exinfo.sdfs.y(1,:)), max(exinfo.sdfs.y(1,:))])
end
%------------------------------------------- drug
s2 = subplot(nplot,1,2);
[~,co_idx_drug]= max(exinfo.sdfs_drug.y(1,:));

% responses
for co =1:length(exinfo.sdfs_drug.y(1,:))
    for i = 1:length(exinfo.sdfs_drug.s)
        plot3(ones(length(exinfo.times_drug),1) * exinfo.sdfs_drug.y(1,co),...
            exinfo.times_drug/10, exinfo.sdfs_drug.s{i, co}, 'Color', c(i,:)); ho
    end
    if ~isempty(exinfo.sdfs_drug.extras)
        plot3(ones(length(exinfo.times_drug),1) * exinfo.sdfs_drug.y(1,co), ...
            exinfo.times_drug/10, exinfo.sdfs_drug.extras{1}.sdf, 'r:'); ho
    end
end

% window for noise calculation
fill([exinfo.times_drug(201)/10,  exinfo.times_drug(201)/10, ...
    exinfo.times_drug(400)/10, exinfo.times_drug(400)/10 ], ...
    [0 ylim_(2)/10 ylim_(2)/10 0], g, 'EdgeColor', g); 


% legend, title and axis specifications
for i = 1:size(exinfo.sdfs_drug.n, 1)
    leg{i} = sprintf('%1.0f \t n=%1.0f', exinfo.sdfs_drug.x(i,co_idx_drug), ...
        exinfo.sdfs_drug.n(i,co_idx_drug)); 
end
if ~isempty(exinfo.sdfs_drug.extras)
    leg{i+1} = ...
        sprintf('blank \t n=%1.0f', exinfo.sdfs_drug.extras{1}.n); 
end

legend(leg, 'Location', 'EastOutside');
xlabel('co');ylabel('time in ms after stimulus onset');

s_drug = horzcat(exinfo.sdfs_drug.s{:, co_idx_drug});
meanfr_drug = mean(mean(s_drug(201:400),2));

title(sprintf('drug lat: %1.1f, dur: %1.1f, \n average sd: %1.2f, meanfr: %1.2f',...
    exinfo.lat_drug, exinfo.dur_drug, ...
    mean(sqrt(exinfo.resvars_drug(201:400, co_idx_drug))), ...
    meanfr_drug));

ylim([0 160]); set(gca, 'XScale', 'log');
grid on;
if nplot > 3
    xlim([min(exinfo.sdfs_drug.y(1,:)), max(exinfo.sdfs_drug.y(1,:))])
end

%--------------------------------- equalize y axis and plot latency line

ylim_ = [0, max([max(get(s1, 'ylim')), max(get(s2, 'ylim'))])]; 
set(s1, 'ylim', ylim_); % equalize y axis
set(s2, 'ylim', ylim_); % equalize y axis

lat = exinfo.lat; lat_drug = exinfo.lat_drug;
dur = exinfo.dur; dur_drug = exinfo.dur_drug;

plot(s1, [lat lat], ylim_, 'k');
plot(s2, [lat_drug lat_drug], ylim_, 'k');

plot(s1, [lat+dur, lat+dur], ylim_, 'k');
plot(s2, [lat_drug+dur_drug, lat_drug+dur_drug], ylim_, 'k');


%--------------------------------- third plot showing normalized sdf dev

s3 = subplot(nplot,1,3);

% amplified deviation to mean response
c = getCol(exinfo);

for i = 1:length(exinfo.sdfs.y(1,:))
    
    plot3(ones(length(exinfo.times),1)* exinfo.sdfs.y(1,i),...
        exinfo.times/10, ...
        sqrt(exinfo.resvars(:,i))./ max(sqrt(exinfo.resvars(:,i))), ...
        'Color', lines(1), 'LineWidth', 1); hold on;
    plot3(ones(length(exinfo.times_drug),1)*exinfo.sdfs_drug.y(1,i),...
        exinfo.times_drug/10, ...
        sqrt(exinfo.resvars_drug(:,i))./ ...
        max(sqrt(exinfo.resvars_drug(:,i))), ...
        c, 'LineWidth', 1);
end


set(gca, 'XScale', 'log');xlabel('co');
ylabel('time');

legend('base', exinfo.drugname);
grid on;
if nplot > 3
    xlim([min(exinfo.sdfs.y(1,:)), max(exinfo.sdfs.y(1,:))])
end
ylim([0 160]);


% -------------------------------- latency
 if nplot > 3
    
    co = exinfo.sdfs.y(1,:);
    [co, coidx] = sort(co);
     
    subplot(nplot*2, 2, nplot*4-1)
    
    plot(co, exinfo.sdfs.lat2hmax(coidx), '.--', 'Color', lines(1)); ho;
    plot(co, exinfo.sdfs_drug.lat2hmax(coidx), '.--', 'Color', c);
    plot(co, exinfo.sdfs.latFP(coidx), '.-', 'Color', lines(1)); ho;
    plot(co, exinfo.sdfs_drug.latFP(coidx), '.-', 'Color', c);
    xlabel('co'); set(gca, 'XScale', 'log');
    title('latency (-fp, - -hmax/2)')
    xlim([min(exinfo.sdfs.y(1,:)), max(exinfo.sdfs.y(1,:))])
    
    
    subplot(nplot*2, 2, nplot*4)
    plot(co, exinfo.sdfs.dur(coidx), '.-', 'Color', lines(1)); ho;
    plot(co, exinfo.sdfs_drug.dur(coidx), '.-', 'Color', c);
    xlabel('co'); set(gca, 'XScale', 'log');
    title('duration (blue:baseline)');
    xlim([min(exinfo.sdfs.y(1,:)), max(exinfo.sdfs.y(1,:))])

    
 end

 



%--------------------------------- save
set(findobj('type', 'axes'), 'fontsize', 8)
savefig(h, exinfo.fig_sdfs);
close(h);

end
