function [mnspk, dose, volt, timeofrec, stim, varargout] = PlotTC( fdir, fname, varargin )
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
ex = loadCluster(fullfile(fdir, fname));
if isfield(ex.Header, 'fileID')
    timeofrec = datenum(ex.Header.fileID);
elseif isfield(ex.Header, 'Headers') 
    timeofrec = datenum(ex.Header.Headers(1).fileID);
elseif isfield(ex, 'fileID')
    timeofrec = datenum(ex.fileID);
else
    warning('could not find the experiment date');
end

if ~isempty(strfind(fname, '5HTSB'))
    drugname = '5HT';
    lstyle = '--';
    dose = getDose(ex); volt = getVolt(ex);
elseif ~isempty(strfind(fname, '5HTKet'))
    drugname = '5HT';
    lstyle = '--';
    dose = getDose(ex); volt = getVolt(ex);
elseif ~isempty(strfind(fname, 'SB'))
    drugname = 'SB';
    lstyle = '--';
    dose = getDose(ex); volt = getVolt(ex);
elseif ~isempty(strfind(fname, 'Ket'))
    drugname = 'Ket';
    lstyle = '--';
   dose = getDose(ex); volt = getVolt(ex);
elseif ~isempty(strfind(fname, '5HT'))
    drugname = '5HT';
    lstyle = '--';
   dose = getDose(ex); volt = getVolt(ex);
elseif ~isempty(strfind(fname, 'NaCl'))
    drugname = 'NaCl';
    lstyle = '--';
   dose = getDose(ex); volt = getVolt(ex);
else
    drugname = 'Baseline';
    lstyle = '-';
    dose = 0; volt = getVolt(ex);
end


type = ex.exp.e1.type;

if isempty(strfind(fname, 'RC'))
    [mnspk, vals, me] = getspkDG(ex, p_flag, drugname, dose, lstyle, type, fname);
else
    res = HN_computeLatencyAndNetSpk([],ex, 'lat_flag', false);
    
    if size(res.netSpikesPerFrame, 2)>1
        [~, idx] = max(res.sdfs.y(1,:));
        mnspk = res.netSpikesPerFrame(:, idx)';
        vals = res.sdfs.x(:, idx);
    else
        mnspk = res.netSpikesPerFrame';
        vals = res.sdfs.x;
    end
    
    if  p_flag
        figure('Name', fname);
        if strcmp(drugname, 'Baseline');
            plot(mnspk, 'Displayname', 'base');
        else
            plot(mnspk, '--', 'Displayname', drugname)
        end
        for i_n = 1:length(mnspk)            
            text(i_n, mnspk(i_n), num2str(res.sdfs.n(i_n)), ...
                'FontSize', 10);
        end
            
    end
end
stim.val = vals;
stim.type = type;
varargout{1} = sort(unique([ex.Trials.(type)]));
varargout{2} = drugname;
end



function [mnspk, vals, me] = getspkDG(ex, p_flag, drugname, dose, lstyle, type, fname)

ex.Trials = ex.Trials([ex.Trials.Reward]== 1);

% preallocate variables
me = unique([ex.Trials.me]);
me = sort(me);
vals = unique([ex.Trials.(type)]);

mnspk = zeros(length(me), length(vals));
semspk = mnspk;
nrep= mnspk;    % number of stimulus repetitions


% loop through ocularity and stimulus variation to derive spk rate
for i_me = 1:length(me)
    for i_vals = 1:length(vals)
        
        trials = ex.Trials([ex.Trials.me]== me(i_me) & ...
            [ex.Trials.(type)]== vals(i_vals) );
       
        n = length(trials);
        
        mnspk(i_me, i_vals) = nanmean( [trials.spkRate] );
        semspk(i_me, i_vals) = nanstd( [trials.spkRate] )/sqrt(n);
        
        nrep(i_me, i_vals) = n;
    end
end



% plot tuning curve
if p_flag
    figure('Name', fname);
    col = lines(length(me));
    
    for i_me = 1:length(me)
        errorbar(mnspk(i_me, vals<1000), semspk(i_me, vals<1000), ...
            'Color',col(i_me, :), 'LineWidth', 1.5, 'LineStyle', lstyle, ...
            'Displayname', num2str(me(i_me)));
        hold on;
        for i_n = 1:length(nrep)            
            text(i_n, mnspk(i_me, i_n), num2str(nrep(i_me, i_n)), ...
                'FontSize', 10);
        end
    end
    
    if any(vals > 1000)
        plot(get(gca, 'XLim'), [mnspk(vals > 1000) mnspk(vals > 1000)], '--');
    end
    
    if isfield(ex.Header, 'Headers')
        Header = ex.Header.Headers(1);
    else
        Header = ex.Header;
    end
    
    legend('show')
    set(gca, 'XTick', 1:length(vals), ...
        'XTickLabel', cellstr(num2str(vals')));
    volt = getVolt(ex);
    
    
    if ~isempty(strfind(fname, '5HTSB'))
        title(sprintf('5HT   %1.0f nA, %1.2f volt \n SB %1.0f nA, %1.2f volt', ...
            dose, ...
            volt(1), ...
            Header.iontophoresisEjectionCurrent(2), ...
            volt(2)) );
            dose = dose(1);
    elseif ~isempty(strfind(fname, '5HTKet'))
        title(sprintf('5HT   %1.0f nA, %1.2f volt \n Ket %1.0f nA, %1.2f volt', ...
            dose, ...
            volt(1), ...
            Header.iontophoresisEjectionCurrent(2), ...
            volt(2)) );
            dose = dose(1);
    elseif ~isempty(strfind(fname, 'Ket'))
        title(sprintf('Ket   %1.0f nA, %1.2f volt', dose, ...
            volt) );    
    elseif ~isempty(strfind(fname, 'SB'))
        title(sprintf('SB   %1.0f nA, %1.2f volt', dose, ...
            volt) );
    elseif ~isempty(strfind(fname, '5HT'))
        title(sprintf('5HT   %1.0f nA, %1.2f volt', dose, ...
            volt) );
    elseif ~isempty(strfind(fname, 'NaCl'))
        title(sprintf('NaCl   %1.0f nA, %1.2f volt', dose, ...
            volt) );
    else
        title(drugname);
    end
    
    xlabel(type); ylabel('spike rate');
end


end




function [dose, volt] = getDose(ex)

dose = nan;

if isfield(ex.Header, 'Headers')
    if isfield(ex.Header.Headers(1), 'iontophoresisEjectionCurrent')
        dose = ex.Header.Headers(1).iontophoresisEjectionCurrent(1);
    end
else
    if isfield(ex.Header, 'iontophoresisEjectionCurrent')
        dose = ex.Header.iontophoresisEjectionCurrent(1);
    end
end
end


function volt = getVolt(ex)

volt = nan;
if isfield(ex.Header, 'Headers')
    if isfield(ex.Header.Headers(1), 'iontophoresisVoltage')
        volt = ex.Header.Headers(1).iontophoresisVoltage;
    end
else
    if isfield(ex.Header, 'iontophoresisVoltage')
        volt = ex.Header.iontophoresisVoltage;
    end
end
end