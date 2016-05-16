function [ dat ] = fctPlotTimeCourseUnit( expInfo, fctname )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
% load all available clusters

dat.x = [];
dat.y = [];
dat.markerfc=[];
dat.marker = {};
dat.expInf = {};

for i = 1:length(expInfo)
    
    fc = ones(1,3);
    
    if expInfo(i).is5HT
        fc = fc*0.5;
    end
    
    switch fctname
        case 'spike rate'
            y_temp = mean(expInfo(i).spkRate_mn_drug);
        case 'gain change'
            y_temp = expInfo(i).gslope;
        case 'wave width'
            y_temp = expInfo(i).wdt;
    end
    
    dat.x = [dat.x, expInfo(i).date];
    dat.y = [dat.y, y_temp];
    dat.marker = [dat.marker, {markerAssignment(expInfo(i).param1)}];
    dat.expInf = [dat.expInf, {expInfo(i)}];
    dat.markerfc = [dat.markerfc; fc];
    
end


% dat.x = dat.x - dat.x(1);
for i = 1:length(dat.x)
    plot(dat.x(i), dat.y(i), ...
        'MarkerFaceColor', dat.markerfc(i, :), ...
        'MarkerEdgeColor', 'k',...
        'Marker', dat.marker{i},...
        'ButtonDownFcn', {@DataPressed, dat.expInf{i}, strcmp(fctname, 'wave width')}); hold on;
end

xlabel('Time Trial Start');
ylabel(fctname);
dat.info = '';



%%% plot line for different mean values
kk = 1;
for t = unique(dat.x)
    mnx(kk) = t;
    mny(kk) = mean(dat.y(dat.x==t));
    mnmark{kk} = dat.marker{find(dat.x==t, 1, 'first')};
    kk= kk+1;
end


for m = unique(mnmark)
    idx = strcmp(mnmark, m);
    
    plot(mnx(idx), mny(idx), ...
       ['-' m{1}], 'MarkerFaceColor', [0 0.5 0]); hold on;
end


hold off;

end

























