function spkavelfp = spktriglfp( exSpk, exLFP, varargin)
%

p_flag = true;
time = 0.08;
rawflag = false;

k = 1;
while k<=length(varargin)
    switch varargin{k}
        case 'time'
            time = varargin{k+1};
        case 'plot'
            p_flag = varargin{k+1};
        case 'rawflag'
            rawflag = varargin{k+1};
    end
    k=k+1;
end

spklfp = []; nspk = 0;
for t = 1:length(exSpk.Trials)
    spk = getSpks(exSpk.Trials(t), rawflag);
    spklfp = [spklfp; getLFP(exLFP.Trials(t), spk, time, rawflag)];
    nspk = nspk+length(spk);
end
spkavelfp = nanmean(spklfp);
stdspklfp = nanstd(spklfp) ./ sqrt(size(spklfp, 2));

%%% plot results
if p_flag
    a1 = fill([-time:0.001:time, fliplr(-time:0.001:time)], ...
        [spkavelfp - stdspklfp , fliplr(spkavelfp + stdspklfp)], 'b');
    a1.FaceColor = [0.5 0.5 0.5]; a1.FaceAlpha = 0.4;
    a1.EdgeColor = 'w'; a1.EdgeAlpha = 0; hold on;
    
    plot(-time:0.001:time, spkavelfp, ...
        'ButtonDownFcn', {@PlotSingleTrials, time, spklfp, spk, exLFP.Trials(t)});
    xlabel('time rel to spk [s]');
    ylabel('avg LFP');
    xlim([-time time]);
    title(sprintf('#spk: %1.0f', nspk));
    crossl
end

end


%%

function spklfp = getLFP(trials, spk, time, rawflag)
% lfp at spike +/- time

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
    
    if rawflag
        spklfp(i,:) = trials.LFP(tstrt-1:tend-1);   %#debugging    
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
    spk = spk (spk> t_strt(1)+0.06 & spk<=t_end-0.06);
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