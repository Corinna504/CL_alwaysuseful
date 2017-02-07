function [fig_h, fig_spect] = LFPGui( exSpkin, exLFPin, exSpkin2, exLFPin2)
% gui showing different LFP related plots:
% raw lfp vs. filtered time series
% raw lfp vs. filtered power
% spike triggered average
% stimulus triggered average
% spike field coherence
%

%%

tag_number = randi(1000,1);

fig_h = figure('Position', [57 188 1100 442]);

fig_spect = findobj('tag', ['spectogram' num2str(tag_number)]);
if isempty(fig_spect)
    fig_spect = figure('tag', ['spectogram' num2str(tag_number)], 'Position', [101   279   989   701]);
else
    figure(fig_spect, 'Position', [101   279   989   701]);
end
            

idx = ~ cellfun(@isempty, {exLFPin.Trials.LFP});
exLFPin.Trials = exLFPin.Trials(idx);
exSpkin.Trials = exSpkin.Trials(idx);

idx2 = ~ cellfun(@isempty, {exLFPin2.Trials.LFP});
exLFPin2.Trials = exLFPin2.Trials(idx2);
exSpkin2.Trials = exSpkin2.Trials(idx2);


params.Fs = 1000; params.trialave = 1; 

%% specifications
bg = uibuttongroup(fig_h, 'Title','Filter and Multitaper', ...
    'Position', [0.03 0.5 0.18 0.45]);

% notch filter
uicontrol(bg, 'Style','text', 'String','Notch', 'Position', [5 160 50 15], ...
    'HorizontalAlignment', 'left');
notchfreqlb_h = uicontrol(bg, 'Style','edit', 'String', '48', 'Position', [45 160 25 15]);
notchfrequb_h = uicontrol(bg, 'Style','edit', 'String', '52', 'Position', [80 160 25 15]);


uicontrol(bg, 'Style','text', 'String', 'order', 'Position', [120 160 50 15], ...
    'HorizontalAlignment', 'left');
notchorder_h = uicontrol(bg, 'Style','edit', 'String', '2', 'Position', [150 160 30 15]);


% lowpass filter
uicontrol(bg, 'Style','text', 'String','Lowpass', 'Position', [5 130 50 15], ...
    'HorizontalAlignment', 'left');
lowpassfreq_h = uicontrol(bg, 'Style','edit', 'String', '250', 'Position', [55 130 30 15]);

uicontrol(bg, 'Style','text', 'String','order', 'Position', [120 130 50 15], ...
    'HorizontalAlignment', 'left');
lowpassorder_h = uicontrol(bg, 'Style','edit', 'String', '2', 'Position', [150 130 30 15]);


% multitaper
uicontrol(bg, 'Style', 'text', 'String','Multitaper Method', 'Position', [5 80 150 15], ...
    'HorizontalAlignment', 'left');
uicontrol(bg, 'Style', 'text', 'String','nw', 'Position', [5 60 50 15], ...
    'HorizontalAlignment', 'left');
nw_h = uicontrol(bg, 'Style','edit', 'String', '3', 'Position', [55 60 30 15]);

%%frequency range to show
uicontrol(bg, 'Style', 'text', 'String','Frequency Range', ...
    'Position', [5 25 100 15], 'HorizontalAlignment', 'left');
freqrange_lb_h = uicontrol(bg, 'Style','edit', 'String', '1', ...
    'Position', [105 25 30 15]);
freqrange_ub_h = uicontrol(bg, 'Style','edit', 'String', '100', ...
    'Position', [140 25 30 15]);


%%window length and step size for spectogram plots
uicontrol(bg, 'Style', 'text', 'String','Specgram Window', ...
    'Position', [5 5 100 15], 'HorizontalAlignment', 'left');
winlength_h = uicontrol(bg, 'Style','edit', 'String', '0.1', ...
    'Position', [105 5 30 15]);
winstep_h = uicontrol(bg, 'Style','edit', 'String', '0.005', ...
    'Position', [140 5 30 15]);


%% update button
[stimparam, valsB] = getStimParam(exSpkin);
[~, valsD] = getStimParam(exSpkin2);
vals = intersect(valsD, valsB); % find the common stimuli 

stimcond_h = uicontrol(fig_h, 'Style', 'popupmenu', 'String', {'all'; num2str(vals')},...
    'Position', [120 120 100 30]);


%% popupmenu for comparison panels
uicontrol(fig_h, 'Style', 'Text', 'String','only comparison (lower plots)',...
    'Position', [5 120 100 30]);

uicontrol(fig_h, 'Style', 'pushbutton', 'String','Update', ...
    'Position', [120 80 100 30], 'Callback', @UpdateAxes)



%% axes
ax_lfp_t = axes(fig_h,'Position', [0.3 0.8 0.1 0.15]); 
ax_lfp_f = axes(fig_h,'Position', [0.45 0.8 0.1 0.15]); 
ax_spktrigavg_t = axes(fig_h,'Position', [0.6 0.8 0.1 0.15]);
ax_spkfieldcoh = axes(fig_h,'Position', [0.75 0.8 0.1 0.15]);
% ax_spectogram = axes(fig_h,'Position', [0.9 0.8 0.1 0.15]);


ax_lfp_t2 = axes(fig_h,'Position', [0.3 0.55 0.1 0.15]); 
ax_lfp_f2 = axes(fig_h,'Position', [0.45 0.55 0.1 0.15]);
ax_spktrigavg_t2 = axes(fig_h,'Position', [0.6 0.55 0.1 0.15]);
ax_spkfieldcoh2 = axes(fig_h,'Position', [0.75 0.55 0.1 0.15]);
% ax_spectogram2 = axes(fig_h,'Position', [0.9 0.55 0.1 0.15]);


ax_lfp_t_cmp = axes(fig_h,'Position', [0.3 0.35 0.1 0.1]); 
ax_lfp_f_cmp = axes(fig_h,'Position', [0.45 0.35 0.1 0.1]);
ax_spktrigavg_t_cmp = axes(fig_h,'Position', [0.6 0.35 0.1 0.1]);
ax_spkfieldcoh_cmp = axes(fig_h,'Position', [0.75 0.35 0.2 0.1]);
% ax_spectogram_cmp = axes(fig_h,'Position', [0.9 0.3 0.1 0.15]);



ax_stimulus_lfp_t  = axes(fig_h,'Position', [0.3 0.15 0.1 0.1]);
ax_stimulus_lfp_f  = axes(fig_h,'Position', [0.45 0.15 0.1 0.1]);
ax_stimulus_stafield_f = axes(fig_h,'Position', [0.6 0.15 0.1 0.1]);
ax_stimulus_coh = axes(fig_h,'Position', [0.75 0.15 0.2 0.1]);



UpdateAxes([], [])
%%
    function UpdateAxes(src, evt)
        
        
        params.tapers = [str2double(nw_h.String), str2double(nw_h.String)*2-1];
        params.fpass =  [str2double(freqrange_lb_h.String), str2double(freqrange_ub_h.String)];
        win = [str2double(winlength_h.String), str2double(winstep_h.String)];
        CallSpectogramPlot;
        
%         delete(fig_h);
%         return
        %------------------------------- baseline condition
        exspk = exSpkin;
        exlfp = exLFPin;
        
        exlfp = frequAnalysis(exlfp,  ...
            'notchf', [str2double(notchfreqlb_h.String)  str2double(notchfrequb_h.String)],...
            'notchord', str2double(notchorder_h.String), ...
            'lowpf', str2double(lowpassfreq_h.String), ...
            'lowpord', str2double(lowpassorder_h.String), ...
            'nw', str2double(nw_h.String));
        
        % LFP time domain
        axes(ax_lfp_t); hold off;   
        lfpave_base = lfpTimeDomain(exlfp);
        
        % LFP frequency domain
        axes(ax_lfp_f); hold off;   
        powave_base = lfpFreqDomain(exlfp, params.fpass);
        
        % Spike Triggered Average
        axes(ax_spktrigavg_t); hold off; 
        spktriglfp( exspk, exlfp, 'plot', true, 'rawflag', true);
        sta_base = spktriglfp(exspk, exlfp, 'plot', true);
        ax_spktrigavg_t.Children(1).LineStyle = '--'; ylim auto

        % Spike Field Coherence
        axes(ax_spkfieldcoh); hold off; 
        [coh_base, fcoh_base] = spkfieldcoh(exspk, exlfp, params); xlim(params.fpass);
        
       
        
        %------------------------------- drug condition
        exspk_drug = exSpkin2;
        exlfp_drug = exLFPin2;
        
        exlfp_drug = frequAnalysis(exlfp_drug, ...
            'notchf', [str2double(notchfreqlb_h.String)  str2double(notchfrequb_h.String)],...
            'notchord', str2double(notchorder_h.String), ...
            'lowpf', str2double(lowpassfreq_h.String), ...
            'lowpord', str2double(lowpassorder_h.String), ...
            'nw', str2double(nw_h.String));
        
        % LFP time domain
        axes(ax_lfp_t2); hold off;   
        lfpave_drug = lfpTimeDomain(exlfp_drug);
        
        % LFP frequency domain
        axes(ax_lfp_f2); hold off;   
        powave_drug = lfpFreqDomain(exlfp_drug, params.fpass);
        
        % Spike Triggered Average
        axes(ax_spktrigavg_t2); hold off; 
        spktriglfp( exspk_drug, exlfp_drug, 'plot', true, 'rawflag', true);
        sta_drug = spktriglfp( exspk_drug, exlfp_drug, 'plot', true); ylim auto
        ax_spktrigavg_t2.Children(1).LineStyle = '--';
        
        % Spike Field Coherence
        axes(ax_spkfieldcoh2); hold off; 
        [coh_drug, fcoh_drug] = spkfieldcoh(exspk_drug, exlfp_drug, params); xlim(params.fpass);
        
        
        
        
        %---------------------------------- comparison
        
        if strcmp(stimcond_h.String(stimcond_h.Value), 'all')
            par = ones(length(exlfp.Trials),1); par = num2cell(par);
            [exlfp.Trials.(stimparam)] = deal( par{:});
            [exspk.Trials.(stimparam)]= deal( par{:});
            
            par = ones(length(exlfp_drug.Trials),1); par = num2cell(par);
            [exlfp_drug.Trials.(stimparam)] = deal( par{:});
            [exspk_drug.Trials.(stimparam)]= deal( par{:});
            
        else
            stimval = str2double(stimcond_h.String(stimcond_h.Value));
            exlfp.Trials = exlfp.Trials([exlfp.Trials.(stimparam)]==stimval);
            exlfp_drug.Trials = exlfp_drug.Trials([exlfp_drug.Trials.(stimparam)]==stimval);
            
            exspk.Trials = exspk.Trials([exspk.Trials.(stimparam)]==stimval);
            exspk_drug.Trials = exspk_drug.Trials([exspk_drug.Trials.(stimparam)]==stimval);
        end
        
        
        % LFP time domain
        axes(ax_lfp_t_cmp); hold off;   
        lfpTimeDomain(exlfp); 
        delete(findobj(ax_lfp_t_cmp, 'LineWidth', 2));
        set(findobj(ax_lfp_t_cmp, 'type', 'line'), 'Color', 'k');
        lfpTimeDomain(exlfp_drug);
        
        % LFP frequency domain
        axes(ax_lfp_f_cmp); hold off;   
        lfpFreqDomain(exlfp, params.fpass); 
        set(findobj(ax_lfp_f_cmp,'type', 'line'), 'Color', 'k');
        lfpFreqDomain(exlfp_drug, params.fpass);
        
        
        % Spike Field Coherence
        axes(ax_spkfieldcoh_cmp); hold off; 
        spkfieldcoh(exspk, exlfp, params); hold on;
        set(findobj(ax_spkfieldcoh_cmp,'type', 'line'), 'Color', 'k');
        spkfieldcoh(exspk_drug, exlfp_drug, params); 
        xlim(params.fpass);
        legend('baseline', 'drug', 'Location', 'EastOutside');
        
        
        % Spike triggered average
        axes(ax_spktrigavg_t_cmp); hold off; 
        spktriglfp( exspk, exlfp, 'plot', true);hold on
        delete(findobj(ax_spktrigavg_t_cmp, 'LineWidth', 2));
        set(findobj(ax_spktrigavg_t_cmp,'type', 'line'), 'Color', 'k');
        hold on
        spktriglfp( exspk_drug, exlfp_drug, 'plot', true);

        title('blue: raw     filtered:red'); ylim auto
        
        %----------------------------- stimulus averaged values
        
        % stimulus vs lfp signal
        axes(ax_stimulus_lfp_t);
        plot(valsB, nanmean(lfpave_base, 2), '.-k', ...
            valsD, nanmean(lfpave_drug, 2), '.-b');
        xlabel('stimulus'); 
        ylabel('averaged signal');
        
        % stimulus vs lfp pow
        axes(ax_stimulus_lfp_f);
        plot(valsB, nanmean(powave_base, 2), '.-k', ...
            valsD, nanmean(powave_drug, 2), '.-b');
        xlabel('stimulus'); 
        ylabel('averaged signal');

        axes(ax_stimulus_coh);
        plot(valsB, nanmean(coh_base, 2), '.-k', ...
            valsD, nanmean(coh_drug, 2), '.-b');
        
        legend('baseline', 'drug', 'Location', 'EastOutside');

        %----------------------------- 
        set(findobj('Type', 'Axes'), 'FontSize', 8);

        
        
    end


    function CallSpectogramPlot
        
        %----------------------------- LFP spectogram
        win = [str2double(winlength_h.String), str2double(winstep_h.String)];

        figure(fig_spect);
        
        exlfp = exLFPin;
        exlfp = frequAnalysis(exlfp, ...
            'notchf', [str2double(notchfreqlb_h.String)  str2double(notchfrequb_h.String)],...
            'notchord', str2double(notchorder_h.String), ...
            'lowpf', str2double(lowpassfreq_h.String), ...
            'lowpord', str2double(lowpassorder_h.String), ...
            'nw', str2double(nw_h.String));
        exlfp_drug = exLFPin2;
        exlfp_drug = frequAnalysis(exlfp_drug, ...
            'notchf', [str2double(notchfreqlb_h.String)  str2double(notchfrequb_h.String)],...
            'notchord', str2double(notchorder_h.String), ...
            'lowpf', str2double(lowpassfreq_h.String), ...
            'lowpord', str2double(lowpassorder_h.String), ...
            'nw', str2double(nw_h.String));
        
                   
       % other stimuli
        for i = 1:length(vals)
          
            % baseline
            s(1,i) = subplot(3, length(vals), i);
            [S,t,f] = lfpspecgram(exlfp, win, params, i);

               
            % drug
            s(2,i) = subplot(3, length(vals), i+length(vals));
            [S_drug,t,f] = lfpspecgram(exlfp_drug, win, params, i);
        
            % time spectrum
            s(3,i) = subplot(3, length(vals), i+length(vals)*2);
            S_diff(:,:,i) = S-S_drug; 
            plot_matrix(S_diff(:,:,i), t+exlfp.Trials(1).LFP_interp_time(1), f);   
            ylabel('Frequency'); xlabel('time [s]');
            
        end
        
        s(1,1).YLabel.String = char('Baseline stimulus triggered', 'Spectogram');
        s(2,1).YLabel.String = char('Drug stimulus triggered', 'Spectogram');
        s(3,1).Title.String = 'log(Base pow)-log(Drug pow)';
        
        set(findobj('Type', 'Axes'), 'FontSize', 8);
        
        for i = 1:length(vals)    
%             caxis(s(3,i), [min(min(min(S_diff))) max(max(max(S_diff)))]);
        end

        axes('Position', [0.05 0.05 0.1 0.01]); 
        text(0, 0, 'Color/Frequency Power is in dB');
        axis off;
    end


end

