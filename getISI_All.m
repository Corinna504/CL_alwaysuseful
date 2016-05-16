function ISI_frct = getISI_All(exinfo, ex0, ex2, p_flag)
% computes the burst index as in Anderson et al. 2013
% I only look for the stimuli response that also elicited the highest
% response, i.e. that is closest to the preferred orientation



% merge inter spike interval from all trials
isi0 = getISI(ex0.Trials);
isi2 = getISI(ex2.Trials);

ISI_frct(1) = sum(isi0<0.005)/length(isi0); 
ISI_frct(2) = sum(isi2<0.005)/length(isi2); 


%% plot results
if p_flag
    
    h = figure('Name',  exinfo.figname);
    col = getCol(exinfo);
    
    isi0 = isi0(isi0<0.3);
    isi2 = isi2(isi2<0.3);
    h0 = histogram(isi0, 100); hold on;
    h0.FaceColor = 'b';
    h1 = histogram(isi2, h0.BinEdges); hold on;
    h1.FaceColor = col;
    xlabel('ISI [s]'); xlim([0, 0.3]);
    set(gca, 'XScale', 'log', 'XTick', [0.005 0.01 0.05 0.1 0.2 0.3])
    
    title( sprintf(['base_{isi<5ms}=%1.2f ' exinfo.drugname '_{isi<5ms}=%1.2f'], ISI_frct) );
    
    plot([0.005 0.005], get(gca, 'ylim'), 'k') 
    savefig(h, exinfo.fig_bri);
    close(h);
    
end

end


function isi = getISI(trials)
% returns the autocorrelation for each trial normalized with the shuffle
% predictor, and the interspike intervals that are  across all
% trials

isi = cell(length(trials));

for i = 1:length(trials)
    
    % select spikes within stimulus presentation range
    t_strt = trials(i).Start - trials(i).TrialStart; % stimuli frame onsets
    ind = trials(i).Spikes > t_strt(1) & trials(i).Spikes < t_strt(end)+0.1;
    spks = trials(i).Spikes(ind);
    
    for j = 1:length(spks)-1
        isi{i} = [isi{i}; spks(j+1:end) - spks(j)];
    end
end

isi = vertcat(isi{:});

end
