function DataPressed(data_h, eventdata, datinfo, xlab, ylab, fig2plot)
% assigns the correct figure path to the data point

xlab_short = xlab ( setdiff(1:length(xlab), regexp(xlab,'drug') : regexp(xlab,'drug')+3) );
xlab_short = xlab_short ( setdiff(1:length(xlab_short), regexp(xlab_short,'base') : regexp(xlab_short,'base')+3) );

ylab_short = ylab ( setdiff(1:length(ylab), regexp(ylab,'drug') : regexp(ylab,'drug')+3) );
ylab_short = ylab_short ( setdiff(1:length(ylab_short), regexp(ylab_short,'base') : regexp(ylab_short,'base')+3) );

if strcmp(xlab_short, ylab_short) || ~isempty(strfind(ylab_short, 'additive change'))
    pt = {xlab};
else
    pt = {xlab ylab};
end


disp(datinfo(1).fname_drug);


j = 1;
pos = 1;
nfig = length(fig2plot);

if any(strcmp(fig2plot, 'Raster'))
    nfig = nfig+1;
elseif any(strcmp(fig2plot, 'LFP'))
    nfig = nfig-1;
    
end


if nfig > 0
    h = figure('Visible', 'off');
end


temp =[];
while j<=length(fig2plot)
    
    switch fig2plot{j}
       
        case 'LFP'
            
            exSpkin = loadCluster(datinfo(1).fname);
            exSpkin2 = loadCluster(datinfo(1).fname_drug);
            if datinfo(1).isc2
                exLFPin = loadCluster(strrep(datinfo(1).fname, 'c2', 'lfp'));
                exLFPin2 = loadCluster(strrep(datinfo(1).fname_drug, 'c2', 'lfp'));
            else
                exLFPin = loadCluster(strrep(datinfo(1).fname, 'c1', 'lfp'));
                exLFPin2 = loadCluster(strrep(datinfo(1).fname_drug, 'c1', 'lfp'));
            end
            
            
            exSpkin.Trials = exSpkin.Trials( [exSpkin.Trials.me] == datinfo(1).ocul);
            exSpkin2.Trials = exSpkin2.Trials( [exSpkin2.Trials.me] == datinfo(1).ocul);
            
            exLFPin.Trials = exLFPin.Trials( [exLFPin.Trials.me] == datinfo(1).ocul);
            exLFPin2.Trials = exLFPin2.Trials( [exLFPin2.Trials.me] == datinfo(1).ocul);

            
            LFPGui( exSpkin, exLFPin, exSpkin2, exLFPin2)
            set(findobj('Type', 'figure'), 'Name', datinfo(1).figname)
            j = j+1;
            continue
            
        case 'Variability'
            temp = figure;
            scatter(datinfo.ratemn, datinfo.ratevars, 'r', 'filled'); hold on;
            scatter(datinfo.ratemn_drug, datinfo.ratevars_drug, 'r');
            title('base: filled, 5HT/NaCl: empty');
            set(gca, 'XLim', [0 max( [ datinfo.ratevars datinfo.ratevars_drug] )],...
                'YLim', [0 max( [ datinfo.ratevars datinfo.ratevars_drug] )]);
            set(gca, 'XScale', 'log', 'YScale', 'log');
            eqax; unity;
            axis square
            
        case 'Tuning Curve'
            if datinfo(1).isRC && ~isempty(strfind(datinfo(1).fname, 'CO'))
                openfig(datinfo(1).fig_tc);
                j = j+1;
                continue
            else
                temp = openfig(datinfo(1).fig_tc, 'invisible');
            end            
        case 'Wave Form'
            datinfo(1).fig_waveform = strrep(datinfo(1).fig_waveform, 'Analysis', 'GeneralFiles');
            temp = openfig(datinfo(1).fig_waveform, 'invisible');
            
        case 'Regression'
            datinfo(1).fig_regl = strrep(datinfo(1).fig_regl, 'Analysis', 'GeneralFiles');
            temp = openfig(datinfo(1).fig_regl, 'invisible');
            
        case 'ISI'
            datinfo(1).fig_bri = strrep(datinfo(1).fig_bri, 'Analysis', 'GeneralFiles');
            temp = openfig(datinfo(1).fig_bri, 'invisible');
            
        case 'Raster'
            datinfo(1).fig_raster = strrep(datinfo(1).fig_raster, 'Analysis', 'GeneralFiles');
            temp = openfig(datinfo(1).fig_raster, 'invisible');
            
            ax = findobj(temp, 'Type', 'axes');
            newax = copyobj(ax, h);
            close(temp);
            
            newax(1).Position = [0.1+(0.9/nfig)*(pos-1)  ...
                0.95 (0.9/nfig-0.05)*2 0.05];
            
            newax(3).Position = [0.1+(0.9/nfig)*(pos-1)  ...
                0.1 0.9/nfig-0.05 0.8];
            
            pos = pos+1;
            newax(2).Position = [0.1+(0.9/nfig)*(pos-1)  ...
                0.1 0.9/nfig-0.05 0.8];
            
            j = j+1;
            pos = pos+1;
            continue
            
        case 'Phase Select.'
            temp = openfig(datinfo(1).fig_phase, 'invisible');
            
        case 'smooth PSTH'
            temp = openfig(datinfo(1).fig_psth);
            ax = findobj(temp, 'Type', 'Axes');
            delete(ax([2,4]))
            
            ylim_ = [0 max( horzcat(ax([3,5]).YLim) )];
            set(ax([3,5]), 'YLim', ylim_);
            %             j = j+1;
            %             continue
            
        case 'Spike Density'
            strrep(datinfo(1).fig_lfpPow, 'Analysis', 'GeneralFiles')
            temp = openfig(datinfo(1).fig_sdfs, 'invisible');
            ax = findobj(temp, 'Type', 'Axes');
    end
    
    
    
    ax = findobj(temp, 'Type', 'axes');
    newax = copyobj(ax, h);    
    
    close(temp);
    
    for i = 1:length(newax)
        newax(i).Position = [0.1+(0.9/nfig)*(pos-1)  ...
            0.12+(0.8/length(newax))*(i-1) ...
            0.85/nfig-0.05 ...
            0.8/length(newax)-0.1];
        newax(i).Title.FontSize = 8;
    end
    
    pos = pos+1;
    j = j+1;
end


if nfig>0
    h.Position = [287   500   350*nfig  450];
    h.Name = datinfo(1).figname;
    h.UserData = datinfo;
    h.Visible = 'on';
end
end