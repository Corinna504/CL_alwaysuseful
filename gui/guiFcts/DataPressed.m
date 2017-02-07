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


% disp(datinfo(1).fname_drug);
% fprintf('Anova Baseline p=%1.3f, Drug: p=%1.3f \n', datinfo(1).p_anova, datinfo(1).p_anova_drug);
% if strcmp(datinfo(1).param1, 'co')
%     fprintf('Add Anova Baseline data<=c50 p=%1.3f, data>c50: p=%1.3f \n', datinfo(1).fitparam.undersmpl(1), datinfo(1).fitparam.undersmpl(2));
%     fprintf('Add Anova Drug data<=c50 p=%1.3f, data>c50: p=%1.3f \n', datinfo(1).fitparam_drug.undersmpl(1), datinfo(1).fitparam.undersmpl(2));
% end


j = 1;
pos = 1;
nfig = length(fig2plot);

if any(strcmp(fig2plot, 'LFP Gui'))
    nfig = nfig-1;
end
if any(strcmp(fig2plot, 'Raster'))
    nfig = nfig-1;
end
if any(strcmp(fig2plot, 'Variability'))
    nfig = nfig-1;
end


if nfig > 0
    h = figure('Visible', 'off');
end


temp =[];
while j<=length(fig2plot)
    
    switch fig2plot{j}
       
        case 'LFP Gui'
            
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
            
            hlfp = LFPGui( exSpkin, exLFPin, exSpkin2, exLFPin2);
            j = j+1;
            continue
            
        case 'Variability'
            h_var = openfig(datinfo(1).fig_varxtime);
            set(h_var, 'UserData', datinfo(1));
            j = j+1;
            pos = pos+1;
            continue
            
            
        case 'Tuning Curve'
            temp = openfig(datinfo(1).fig_tc, 'invisible');
            
        case 'Wave Form'
            temp = openfig(datinfo(1).fig_waveform, 'invisible');
            
        case 'Regression'
            temp = openfig(datinfo(1).fig_regl, 'invisible');
            
        case 'ISI'
            temp = openfig(datinfo(1).fig_bri, 'invisible');
            
        case 'LFP spk avg'
            temp = openfig(datinfo(1).fig_lfpAvgSpk, 'invisible');
            
        case 'LFP t & pow'
            openfig(datinfo(1).fig_lfpPow);
            j = j+1;
            pos = pos+1;
            continue
            
        case 'Raster'
            h_raster = openfig(datinfo(1).fig_raster);
            set(h_raster, 'UserData', datinfo(1));
            j = j+1;
            pos = pos+1;
            continue
            
        case 'Phase Select.'
            temp = openfig(datinfo(1).fig_phase);  
            if exist( datinfo(1).fig_phasetf )
                temp = openfig(datinfo(1).fig_phasetf);
            end
            j = j+1; 

            continue
        case 'smooth PSTH'
            temp = openfig(datinfo(1).fig_psth);
            ax = findobj(temp, 'Type', 'Axes');
            delete(ax([2,4]))
            
            ylim_ = [0 max( horzcat(ax([3,5]).YLim) )];
            set(ax([3,5]), 'YLim', ylim_);
            %             j = j+1;
            %             continue
            
        case 'Spike Density'
%                 openfig([datinfo(1).fig_sdfs(1:end-4) '_mlfit_drug.fig']);
%                 openfig([datinfo(1).fig_sdfs(1:end-4) '_mlfit_base.fig']);
                
%             dir2 = 'C:\Users\Corinna\Documents\CODE\Sandbox\RC_orcomp_vs_blank\';
%             openfig( [dir2 datinfo(1).figname '.fig']);
            try
                openfig(datinfo(1).fig_latjackknife);
            end
            temp = openfig(datinfo(1).fig_sdfs, 'invisible');
           
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