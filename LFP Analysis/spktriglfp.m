function spkavelfp = spktriglfp( exSpk, exLFP, varargin)
% spike triggered average lfp signal 
%

p_flag = true;
time = 0.08;
rawflag = false;
linestyle = '-';
k = 1; dname = 'filt';
while k<=length(varargin)
    switch varargin{k}
        case 'time'
            time = varargin{k+1};
        case 'plot'
            p_flag = varargin{k+1};
        case 'rawflag'
            rawflag = varargin{k+1};
            linestyle = ':';
            dname = 'raw';

    end
    k=k+1;
end

% find spikes and estimate the lfp +/- time t around it
spklfp = []; nspk = 0;
for t = 1:length(exSpk.Trials)
    spk = getSpks(exSpk.Trials(t), rawflag);
    spklfp = [spklfp; getLFP(exLFP.Trials(t), spk, time, rawflag)];
    nspk = nspk+length(spk);
end
spkavelfp = nanmean(spklfp, 1);
stdspklfp = nanstd(spklfp, 0, 1) ./ sqrt(size(spklfp, 2));

%%% plot results
if p_flag
    a1 = fill([-time:0.001:time, fliplr(-time:0.001:time)], ...
        [spkavelfp - stdspklfp , fliplr(spkavelfp + stdspklfp)], 'b');
    a1.FaceColor = [0.5 0.5 0.5]; a1.FaceAlpha = 0.4;
    a1.EdgeColor = 'w'; a1.EdgeAlpha = 0; hold on;
    
    plot(-time:0.001:time, spkavelfp, 'Color',  lines(1), ...
     'LineWidth', 2, 'LineStyle', linestyle, 'displayname', dname);
    %,...
     %   'ButtonDownFcn', {@PlotSingleTrials, time, spklfp, spk, exLFP.Trials(t)});
    xlabel('time rel to spk [s]');
    ylabel('avg LFP');
    xlim([-time time]);
    title(sprintf('#spk: %1.0f', nspk));
end

end


%%

function spklfp = getLFP(trials, spk, time, rawflag)
% lfp at spk +/- time

if ~rawflag
    spk = spk (spk>time & spk<=0.45-time); % turn off for debugging
end

spklfp = nan(length(spk), length(-time:1/1000:time));
for i = 1:length(spk)
    if rawflag
        tspk = find(trials.LFP_ts >= spk(i), 1, 'first') ; %#debugging
    else
        tspk = find(trials.LFP_interp_time <= spk(i), 1, 'last') ;
    end
    
    tstrt = tspk-(time*1000);
    tend = tstrt+size(spklfp,2)-1;
    
    % assign the spk centered LFP to the final matrix
    if rawflag
        l = length(trials.LFP);
        if tend-1<=l
            spklfp(i,:) = trials.LFP(tstrt-1:tend-1);
        else
            spklfp(i,1:l-tstrt+1) = trials.LFP(tstrt-1:l-1);   
            spklfp(i,l-tstrt+2:end) = nan;
        end
    else
        spklfp(i,:) = trials.LFP_interp(tstrt:tend);
    end
end

end


function spk = getSpks(trials, rawflag)
% spikes within the stimulus presentation time
t_strt = trials.Start - trials.TrialStart;
t_end = t_strt(end)+mean(diff(t_strt));

if rawflag
    %#debugging
    spk = trials.Spikes( trials.Spikes >= t_strt(1) & ...
        trials.Spikes <= t_end);
    spk = round(spk*1000)/1000;
else
    spk = trials.Spikes( trials.Spikes >= t_strt(1) & ...
        trials.Spikes <= t_end) - t_strt(1);
    spk = round(spk*1000)/1000;
end

end


%% Callback Function
function PlotSingleTrials(~,~,time, stlfp, spk, trials)
figure;

subplot(1,2,1)
plot(trials.LFP_interp_time, trials.LFP_interp); hold on;
plot(spk, ones(size(spk)), 'x' ); hold on; crossl
xlim([0, 0.45]);

ax = subplot(1,2,2);
for i = 1:size(stlfp,1)
    plot(-time:0.001:time, stlfp(i,:)); hold on;
end
set(findobj(ax, 'Type', 'Line'), 'Color', [0 0.2 0.2 0.2], 'LineWidth',2);
plot(-time:0.001:time, nanmean(stlfp), 'k'); hold on;

title('Single Trials Spk Avg LFP'); crossl
end