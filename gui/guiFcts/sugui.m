function sugui

%% predefining
guiprop = PlotProps();
load('expInfo0311_a.mat', 'expInfo');

analysisOpts = guiprop.analysisOpts;
clusterOpts = {'choose cluster', 'c1', 'c1/c0', 'lfp'};
axisopts = guiprop.axisOpts;
% axisopts = strrep(axisopts, 'experiment time', 'trial time');

colorOpts = guiprop.faceColorOpts;
markerOpts = guiprop.markerOpts;
markerfacecol = guiprop.markerfacecol;

dat = [];
margins = 0.03;

incl_i = 1:length(expInfo);


%% preloading


load 'SU_fdir.mat' 'SU_fdir';

% prefix
fdir0 = cellfun(@(x) x(1:19), SU_fdir, 'UniformOutput', false);
fdir0_shown = unique(fdir0);
fname_pref = fdir0_shown{1};

% suffix
fdir1 = cellfun(@(x) x(20:end), SU_fdir, 'UniformOutput', false);
fdir1_shown = fdir1( cell2mat(cellfun(@(x) ~isempty(strfind(x, fname_pref)), SU_fdir,  ...
            'UniformOutput', false))); 
fname_selected = cellfun(@(x) [fname_pref x], fdir1_shown(1:2), ...
            'UniformOutput', false);


%%  gui code

sz = get(0, 'Screensize');
fig_h = figure('Position', [sz(3)*0.2 sz(4)*0.25 sz(3)*0.6 sz(4)*0.5]);
pos = get(fig_h, 'position');
fname_selected = SU_fdir(1:2);


%------------------------- session popup
session_h = uicontrol(fig_h, 'Style', 'popupmenu',...
    'String',   fdir0_shown, ...
    'Position', [pos(3)*margins pos(4)*0.7 pos(3)*0.22 pos(4)*0.1], ...
    'Min', 1,   'Max', 1,...
    'Callback', @SessionSelected);

%---------------------------- file panel
file_h = uicontrol(fig_h, 'Style', 'listbox',...
    'String',   fdir1_shown, ...
    'Position', [pos(3)*margins pos(4)*0.4 pos(3)*0.22 pos(4)*0.3], ...
    'Min', 1,   'Max', 1,...
    'Callback', @FnameSelected);

%------------- checkbox X Y specification
check_XY = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'specifiy x and y',...
    'BackgroundColor', [0.8 0.8 0.8],...
    'Position', [pos(3)*0.3 pos(4)*0.85 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateOptions);

%----------- popmenu with analysis options
popX_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', clusterOpts,...
    'Position', [pos(3)*0.3 pos(4)*0.75 pos(3)*0.15 pos(4)*0.1],...
    'Callback', '');

%----------- popmenu with analysis options
popY_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', analysisOpts,...
    'Position', [pos(3)*0.3 pos(4)*0.7 pos(3)*0.15 pos(4)*0.1],...
    'Callback', '');

%------------------ checkbox for inclusion
checkbestR_h = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'only best fit',...
    'Position', [pos(3)*0.3 pos(4)*0.66 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateInclusion);

check5HT_h = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'only 5HT',...
    'Position', [pos(3)*0.3 pos(4)*0.59 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateInclusion);

checkNaCl_h = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'only NaCl',...
    'Position', [pos(3)*0.3 pos(4)*0.52 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateInclusion);

checkRC_h = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'exclude RC',...
    'Position', [pos(3)*0.3 pos(4)*0.45 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateInclusion);

checkADAPT_h = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'exclude adapt',...
    'Position', [pos(3)*0.3 pos(4)*0.38 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateInclusion);

%------------------------- r2 restriction
txt = uicontrol('Style','text',...
    'Position',[pos(3)*0.3 pos(4)*0.29 pos(3)*0.15 pos(4)*0.1],...
    'String','R2 ', ...
    'HorizontalAlignment', 'left');
editr2_h = uicontrol('Style','edit',...
    'Position',[pos(3)*0.32 pos(4)*0.37 pos(3)*0.03 pos(4)*0.03], ...
    'String', '> 0.72', ...
    'Callback', @UpdateInclusion);

%------------------------- gain restriction
txt2 = uicontrol('Style','text',...
    'Position',[pos(3)*0.3 pos(4)*0.26 pos(3)*0.15 pos(4)*0.1],...
    'String','gain ', ...
    'HorizontalAlignment', 'left');

editgain_h = uicontrol('Style','edit',...
    'Position',[pos(3)*0.32 pos(4)*0.33 pos(3)*0.03 pos(4)*0.03], ...
    'String', '> 0' , ...
    'Callback', @UpdateInclusion);


%------------------------ popup for Color
popColor_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', colorOpts,...
    'Position', [pos(3)*0.3 pos(4)*0.2 pos(3)*0.15 pos(4)*0.1],...
    'Callback', '');

%------------- popup for different Marker
popMarker_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', markerOpts,...
    'Position', [pos(3)*0.3 pos(4)*0.15 pos(3)*0.15 pos(4)*0.1],...
    'Callback', '');

%---------------------------- plot button
but_plot = uicontrol(fig_h,...
    'Style', 'pushbutton',...
    'Position', [pos(3)*0.35 pos(4)*margins pos(3)*0.08 pos(4)*0.05],...
    'String',   'plot', ...
    'Callback', @plotData);

%----------------------------- unity line
but_plot = uicontrol(fig_h,...
    'Style', 'pushbutton',...
    'Position', [pos(3)*0.75 pos(4)*margins pos(3)*0.08 pos(4)*0.05],...
    'String',   'plot unity', ...
    'Callback', @plotUnity);


%------------------- export figure button
but_exp = uicontrol(fig_h,...
    'Style', 'pushbutton',...
    'Position', [pos(3)*0.85 pos(4)*margins pos(3)*0.08 pos(4)*0.05],...
    'String',   'export', ...
    'Callback', @exportPlot);

%------------------------- hold on button
checkhold_h = uicontrol(fig_h,...
    'Style', 'checkbox',...
    'Position', [pos(3)*margins pos(4)*margins pos(3)*0.08 pos(4)*0.05],...
    'String',   'hold on', ...
    'Callback', '');


%--------------------------- text message
txt_warn = uicontrol(fig_h, 'Style', 'text', ...
    'HorizontalAlignment', 'left',...
    'BackgroundColor', [0.8 0.8 0.8],...
    'Position', [pos(3)*0.5 pos(4)*margins pos(3)*0.1 pos(4)*0.08],...
    'String', 'INFO');

%% nested functions

% export plot
    function exportPlot(but_exp, eventdata)
        
        figure();
        plotData(but_plot, eventdata)
        ylim_ = get(gca, 'YLim');
        xlim_ = get(gca, 'XLim');
        if ~get(check_XY, 'Value')
            
            if mod(get(file_h, 'Value'),2)
                if expInfo(get(file_h, 'Value'),2).is5HT
                    title([dat.info ' 5HT']);
                else
                    title([dat.info ' NaCl']);
                end
            else
                title([dat.info ' Base']);
            end
            
        end
            
        
        set(gca, 'OuterPosition', [0 0 1 1])
    end

% -------------------------------------------------------------------------
% plot according to entered options
    function plotData(but_plot, eventdata)
        
        UpdateInclusion(check5HT_h, eventdata);
        
        if (get(popY_h, 'Value') == 1) || (get(popX_h, 'Value') == 1)
            delete(gca);
            set(txt_warn, 'String', 'select analysis option');
            
            
        elseif get(check_XY, 'Value')
            fctX = axisopts{get(popX_h, 'Value')-1};
            fctY = axisopts{get(popY_h, 'Value')-1};
            dat = evalMU(fctX, fctY,...
                          'all', 'all', ...
                            expInfo(incl_i));
            
            for i = 1:length(dat.x)
                plot(dat.x(i), dat.y(i), 'o', ...
                    'ButtonDownFcn', {@DataPressed, expInfo(incl_i(i)), ...
                     ~isempty(strfind(fctX, 'wave')) || ~isempty(strfind(fctY, 'wave'))});
                hold on;
            end
            xlabel(dat.xlab); ylabel(dat.ylab);
            hold off;
            
        else
            
            disp('looking to plot...');
            fct_selected        = analysisOpts{get(popY_h, 'Value')};
            cluster_selected    = clusterOpts{get(popX_h, 'Value')};
            set(txt_warn, 'String', '');
            
            %%% plot (single) unit behavior
            if strcmp(fct_selected, 'ALL: fano factor (Mitchel)')
                dat = fctMitchel(expInfo(incl_i));
            else
                set(txt_warn, 'String', 'processing...');
                dat = evalSU(fname_selected, get(file_h, 'Value'), ...
                    fct_selected, ...
                    cluster_selected, expInfo(get(file_h, 'Value')), expInfo(incl_i));
            end
            
            set(txt_warn, 'String', dat.info);
            hold off;
        end
        
        set(gca, 'OuterPosition', [0.45 .1 .55 .9])
        set(gcf, 'UserData', dat);
        
        if get(checkhold_h, 'Value')
            hold on;
        end
           
            
    end

%-------------------------------------------------------------------------
    function UpdateOptions(check_xy, eventdata)
        
        if get(check_xy, 'Value')
            set(popX_h, 'String', [{'x'}, axisopts], 'Value', 1);
            set(popY_h, 'String', [{'y'}, axisopts], 'Value', 1);
        else
            set(popX_h, 'String', clusterOpts, 'Value', 1);
            set(popY_h, 'String', analysisOpts, 'Value', 1);
            
        end
    end

%-------------------------------------------------------------------------
    function UpdateInclusion(check_incl, eventdata)
        incl_i = 1:length(expInfo);
        
        UpdateInclusionHelper(get(check5HT_h, 'Value'),  '[expInfo.is5HT]');
        UpdateInclusionHelper(get(checkNaCl_h, 'Value'),  '~[expInfo.is5HT]');
        UpdateInclusionHelper(get(checkADAPT_h, 'Value'),  '~[expInfo.isadapt]');
        UpdateInclusionHelper(get(checkRC_h, 'Value'),  '~[expInfo.isRC]');
        UpdateInclusionHelper(get(checkbestR_h, 'Value'),  '~[expInfo.valid]');

        
%         UpdateInclusionHelper(strcmp(colorOpts{get(popColor_h, 'Value')}, 'R2'), ...
%                               ['[expInfo.rsqr4both] ' get(editr2_h, 'String')]);
%         UpdateInclusionHelper(strcmp(colorOpts{get(popColor_h, 'Value')}, 'gainchange'),...
%             ['[expInfo.gslope] ' get(editgain_h, 'String')]);


        UpdateInclusionHelper(1, ['[expInfo.rsqr4both] ' get(editr2_h, 'String')]);
        UpdateInclusionHelper(1, ['[expInfo.gslope] ' get(editgain_h, 'String')]);
    end

    function UpdateInclusionHelper(val, cond)
        if val
            eval(['incl_i = intersect( incl_i, find(' cond '));']);
        end
    end

%-------------------------------------------------------------------------
    function FnameSelected(list_h, eventdata)
        idx = getFileIdx(get(file_h, 'Value'));
        
        fname_selected = cellfun(@(x) [fname_pref x], fdir1_shown(idx), ...
            'UniformOutput', false);
        
    end

%-------------------------------------------------------------------------
    function plotUnity(but_h, eventdata)
       unity();
    end

%-------------------------------------------------------------------------
    function SessionSelected(popSession_h, eventdata)
        
        fname_pref = fdir0_shown{get(popSession_h, 'Value')};
        
        fdir1_shown = fdir1( cell2mat(cellfun(@(x) ~isempty(strfind(x, fname_pref)), SU_fdir,  ...
            'UniformOutput', false))); 

        set(file_h, 'Value', 1);
        set(file_h, 'String', fdir1_shown);
        
        fname_selected = cellfun(@(x) [fname_pref x], fdir1_shown(1:2), ...
            'UniformOutput', false);
    end

end




function idx = getFileIdx(i1)

if mod(i1,2)
    idx = [i1, i1+1];
else
    idx = [i1, i1-1];
end

end



