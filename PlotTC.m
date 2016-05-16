function [mnspk, dose, timeofrec] = PlotTC( fdir, fname, varargin )
% gives a first climps on the tuning curve of the file


j = 1;
p_flag = true;
while j<= length(varargin)
    switch varargin{j}
        case 'plot'
            p_flag = varargin{j+1};
    end
    j=j+1;
end


% load file
load(fullfile(fdir, fname));
if isfield(ex.Header, 'fileID')
    timeofrec = datenum(ex.Header.fileID);
elseif isfield(ex.Header, 'Headers') 
    timeofrec = datenum(ex.Header.Headers(1).fileID);
else
    warning('could not find the experiment date');
end

if ~isempty(strfind(fname, '5HTSB'))
    drugname = '5HT';
    lstyle = '--';
    dose = ex.Header.iontophoresisEjectionCurrent(1);
    
elseif ~isempty(strfind(fname, '5HTKet'))
    drugname = '5HT';
    lstyle = '--';
    dose = ex.Header.iontophoresisEjectionCurrent(1);
    
elseif ~isempty(strfind(fname, 'SB'))
    drugname = 'SB';
    lstyle = '--';
    dose = ex.Header.iontophoresisEjectionCurrent;
    
elseif ~isempty(strfind(fname, 'Ket'))
    drugname = 'Ket';
    lstyle = '--';
    dose = ex.Header.iontophoresisEjectionCurrent;
    
elseif ~isempty(strfind(fname, '5HT'))
    drugname = '5HT';
    lstyle = '--';
    dose = ex.Header.iontophoresisEjectionCurrent;
elseif ~isempty(strfind(fname, 'NaCl'))
    drugname = 'NaCl';
    lstyle = '--';
    dose = ex.Header.iontophoresisEjectionCurrent;
else
    drugname = 'Baseline';
    lstyle = '-';
    dose = 0;
end



if ~isempty(strfind(fname, 'CO'))
    stim = 'co';
elseif ~isempty(strfind(fname, 'OR'))
    stim = 'or';
elseif ~isempty(strfind(fname, 'SF'))
    stim = 'sf';
elseif ~isempty(strfind(fname, 'TF'))
    stim = 'tf';
elseif ~isempty(strfind(fname, 'SZ'))
    stim = 'sz';
else
   error('do not know which parameter was manipulated'); 
end


% preallocate variables
me = unique([ex.Trials.me]);
me = sort(me);
vals = unique([ex.Trials.(stim)]);

mnspk = nan(length(me), length(vals));
sdspk = mnspk;
ntrial= mnspk;


% loop through ocularity and stimulus variation to derive spk rate
for i_me = 1:length(me)
    for i_vals = 1:length(vals)
        
        trials = ex.Trials( [ex.Trials.Reward]== 1 & ...
            [ex.Trials.me]== me(i_me) & ...
            [ex.Trials.(stim)]== vals(i_vals) );
        
        
        n = length(trials);
        spkrate = nan(1, n);
        
        for i  = 1:n
            
            t_strt = trials(i).Start - trials(i).TrialStart;
            t_strt = [t_strt t_strt(end)+mean(diff(t_strt))];
            
            spk = trials(i).Spikes >= t_strt(1) & ...
                trials(i).Spikes <= t_strt(end);
            
            spkrate(i) = sum(spk) / (t_strt(end)-t_strt(1));
        end
        
        mnspk(i_me, i_vals) = nanmean( spkrate );
        sdspk(i_me, i_vals) = nanstd( spkrate );
        
        ntrial(i_me, i_vals) = n;
    end
end


% plot tuning curve
if p_flag
    figure('Name', fname);
    col = lines(length(me));
    
    for i_me = 1:length(me)
        errorbar(mnspk(i_me, :), sdspk(i_me, :), ...
            'Color',col(i_me, :), 'LineWidth', 1.5, 'LineStyle', lstyle);
        hold on;
        for i_n = 1:length(ntrial)            
            text(i_n, mnspk(i_me, i_n), num2str(ntrial(i_me, i_n)), ...
                'FontWeight', 'bold');
        end
    end
    
    legend(cellstr(num2str(me')));
    set(gca, 'XTick', 1:length(vals), ...
        'XTickLabel', cellstr(num2str(vals')));
    
    plot(get(gca, 'xlim'), [0 0], 'Color', [0.5 0.5 0.5]);
    
    if ~isempty(strfind(fname, '5HTSB'))
        title(sprintf('5HT   %1.0f nA, %1.2f volt \n SB %1.0f nA, %1.2f volt', ...
            dose, ...
            ex.Header.iontophoresisVoltage(1), ...
            ex.Header.iontophoresisEjectionCurrent(2), ...
            ex.Header.iontophoresisVoltage(2)) );
        dose = dose(1);
    elseif ~isempty(strfind(fname, '5HTKet'))
        title(sprintf('5HT   %1.0f nA, %1.2f volt \n Ket %1.0f nA, %1.2f volt', ...
            dose, ...
            ex.Header.iontophoresisVoltage(1), ...
            ex.Header.iontophoresisEjectionCurrent(2), ...
            ex.Header.iontophoresisVoltage(2)) );
        dose = dose(1);
    elseif ~isempty(strfind(fname, 'Ket'))
        title(sprintf('Ket   %1.0f nA, %1.2f volt', dose, ...
            ex.Header.iontophoresisVoltage) );    
    elseif ~isempty(strfind(fname, 'SB'))
        title(sprintf('SB   %1.0f nA, %1.2f volt', dose, ...
            ex.Header.iontophoresisVoltage) );
    elseif ~isempty(strfind(fname, '5HT'))
        title(sprintf('5HT   %1.0f nA, %1.2f volt', dose, ...
            ex.Header.iontophoresisVoltage) );
    elseif ~isempty(strfind(fname, 'NaCl'))
        title(sprintf('NaCl   %1.0f nA, %1.2f volt', dose, ...
            ex.Header.iontophoresisVoltage) );
    else
        title(drugname);
    end
    
    xlabel(stim); ylabel('spike rate');
end


end

