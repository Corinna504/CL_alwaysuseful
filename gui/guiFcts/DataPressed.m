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



h = figure;

j = 1;
temp =[];
while j<=length(fig2plot)
    
    switch fig2plot{j}
       
       case 'Tuning Curve'
           temp = openfig(datinfo(1).fig_tc, 'invisible');
           
        case 'LFP'
            temp = openfig(datinfo(1).fig_lfpPow, 'invisible');
            
        case 'Wave Form'
            temp = openfig(datinfo(1).fig_waveform, 'invisible');
           
        case 'Regression'
            temp = openfig(datinfo(1).fig_regl, 'invisible');
            
        case 'ISI'
            temp = openfig(datinfo(1).fig_bri, 'invisible');
            
        case 'Raster'
            temp = openfig(datinfo(1).fig_raster, 'invisible');
            
        case 'Spike Density'
            temp = openfig(datinfo(1).fig_sdfs, 'invisible');
            ax = findobj(temp, 'Type', 'Axes');
            set(findobj(ax(1), 'LineStyle', '-'), ...
                'Color', 'b', 'LineWidth', 1.5);
            set(findobj(ax(1), 'LineStyle', '--'), ...
                'LineStyle', '-', 'LineWidth', 1.5);
            ax(1).XLim = [0 160];
            ax(2).XTick = [];   ax(3).XTick = [];
            ax(1).XLabel.String = ax(2).XLabel.String ;
            ax(2).XLabel.String = '';
            
    end
    
    

    ax = findobj(temp, 'Type', 'axes');
    newax = copyobj(ax, h);
    close(temp);
    
    for i = 1:length(newax)
        newax(i).Position = [0.1+(0.9/length(fig2plot))*(j-1)  ...
            0.12+(0.8/length(newax))*(i-1) ...
            0.9/length(fig2plot)-0.05 ...
            0.8/length(newax)-0.1];
    end
    
    j = j+1;
end

h.Position = [287   500   350*length(fig2plot)  450];
h.Name = datinfo(1).figname;
h.UserData = datinfo;

end