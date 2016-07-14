function mugui(expInfo)

if nargin == 0
    load('C:\Users\Corinna\Documents\CODE\CL_alwaysuseful\expInfo.mat', 'expInfo');
end

expInfo = expInfo([expInfo.rsqr_both]>0);
expInfo = addLM2Struct(expInfo);
expInfo = addStruct(expInfo);

guiprop = PlotProps();
fig2plot = {};

%% predefining

axisopts = guiprop.axisOpts;

markerfacecol = guiprop.markerfacecol;

colorOpts = guiprop.faceColorOpts;
edgeColorOpts = guiprop.edgeColorOpts;
markerOpts = guiprop.markerOpts;
datacrit = guiprop.datacrit;

stimulicond = guiprop.stimulicond;
eyeopts = guiprop.eyeopts;

markeredge = zeros(length(expInfo) ,3);
markerface = zeros(length(expInfo) ,3);
marker = repmat({'^'}, length(expInfo), 1);

dat = [];
margins = 0.03;
incl_i = 1:length(expInfo);

%%  gui code

sz = get(0, 'Screensize');
fig_h = figure('Position', [sz(3)*0.2 sz(4)*0.25 sz(3)*0.6 sz(4)*0.6], 'CloseRequestFcn', @my_closereq);
pos = get(fig_h, 'position');


%------------------------- popmenu for Y
popY_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', [{'y'} axisopts],...
    'Position', [pos(3)*0.2 pos(4)*0.8 pos(3)*0.15 pos(4)*0.1],...
    'Callback', '');

%-------------------------- popmenu for X
popX_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', [{'x'} axisopts],...
    'Position', [pos(3)*0.2 pos(4)*0.6 pos(3)*0.15 pos(4)*0.1],...
    'Callback', '');

%------------------ checkbox for inclusion
addUnity = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'unity',...
    'Position', [pos(3)*margins pos(4)*0.6 pos(3)*0.15 pos(4)*0.1]);

addCross = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'cross',...
    'Position', [pos(3)*margins pos(4)*0.54 pos(3)*0.15 pos(4)*0.1]);

addRegress = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'regression',...
    'Position', [pos(3)*margins pos(4)*0.48 pos(3)*0.15 pos(4)*0.1]);

eqAxes = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'equal axes',...
    'Position', [pos(3)*margins pos(4)*0.42 pos(3)*0.15 pos(4)*0.1]);

addHistograms = uicontrol(fig_h, ....
    'Style',  'checkbox',...
    'String', 'histogram',...
    'Position', [pos(3)*margins pos(4)*0.34 pos(3)*0.15 pos(4)*0.1]);


%------------------------- r2 gain fit restriction
txt = uicontrol(fig_h, 'Style','text',...
    'Position',[pos(3)*margins pos(4)*0.165 pos(3)*0.15 pos(4)*0.1],...
    'String','R2 reg', ...
    'HorizontalAlignment', 'left');
editr2_h = uicontrol(fig_h, 'Style','edit',...
    'Position',[pos(3)*(margins+0.05) pos(4)*0.24 pos(3)*0.04 pos(4)*0.03], ...
    'String', ' > -inf ', ...
    'Callback', @UpdateInclusion);

%------------------------- gain restriction
txt2 = uicontrol(fig_h, 'Style','text',...
    'Position',[pos(3)*margins pos(4)*0.105 pos(3)*0.15 pos(4)*0.1],...
    'String','latency ', ...
    'HorizontalAlignment', 'left');
editlatency_h = uicontrol(fig_h, 'Style','edit',...
    'Position',[pos(3)*(margins+0.05) pos(4)*0.18 pos(3)*0.04 pos(4)*0.03], ...
    'String', ' > -inf ' , ...
    'Callback', @UpdateInclusion);


%------------------------- r2 gauss fit restriction
txt3 = uicontrol(fig_h, 'Style','text',...
    'Position',[pos(3)*margins pos(4)*0.045 pos(3)*0.15 pos(4)*0.1],...
    'String','R2 gauss ', ...
    'HorizontalAlignment', 'left');
editr2gauss_h = uicontrol(fig_h, 'Style','edit',...
    'Position',[pos(3)*(margins+0.05) pos(4)*0.12 pos(3)*0.04 pos(4)*0.03], ...
    'String', ' > -inf ' , ...
    'Callback', @UpdateInclusion);


% %--------------------------- popup for Color
% %
% popM_h = uicontrol(fig_h, ....
%     'Style',  'popupmenu',...
%     'String', markerOpts,...
%     'Position', [pos(3)*margins pos(4)*0.7 pos(3)*0.15 pos(4)*0.1],...
%     'Callback', @editMarker);

%--------------------------- popup for Data Criteria
popC_h = uicontrol(fig_h, ....
    'Style',  'popupmenu',...
    'String', datacrit,...
    'Position', [pos(3)*margins pos(4)*0.7 pos(3)*0.15 pos(4)*0.1],...
    'Callback', @UpdateInclusion);

%--------------------------- radiobuttons for monkeys
bg = uibuttongroup(...
    'Position', [0.03 0.82 0.15 0.15]);
              
% Create three radio buttons in the button group.
r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','both',...
                  'Position',[1 5 100 15]);
              
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','mango',...
                  'Position',[1 35 100 15]);

r3 = uicontrol(bg,'Style','radiobutton',...
                  'String','kaki',...
                  'Position',[1 65 100 15]);

%---------------------------- plot button
uicontrol(fig_h,...
    'Style', 'pushbutton',...
    'Position', [pos(3)*0.35 pos(4)*margins pos(3)*0.08 pos(4)*0.05],...
    'String',   'plot', ...
    'Callback', @createPlot);


%----------------------- close all button
uicontrol(fig_h, ...
    'Style', 'pushbutton', ...
    'Position', [pos(3)*0.75 pos(4)*margins pos(3)*0.08 pos(4)*0.05], ...
    'String', 'close all' ,...
    'Callback', @CloseAll);

%------------------- export figure button
uicontrol(fig_h,...
    'Style', 'pushbutton',...
    'Position', [pos(3)*0.85 pos(4)*margins pos(3)*0.08 pos(4)*0.05],...
    'String',   'export', ...
    'Callback', @exportPlot);

%------------------------- export barplot
uicontrol(fig_h,...
    'Style', 'pushbutton',...
    'Position', [pos(3)*0.95 pos(4)*margins pos(3)*0.04 pos(4)*0.05],...
    'String',   'bar xy', ...
    'Callback', @exportBar);


%------------------------ popup for stimuli condition
pop_Yspec = uicontrol(fig_h,...
    'Style', 'popupmenu',...
    'String', stimulicond,...
    'Position',[pos(3)*0.2 pos(4)*0.8 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateInclusion);

pop_Xspec = uicontrol(fig_h,...
    'Style','popupmenu',...
    'String', stimulicond,...
    'Position',[pos(3)*0.2 pos(4)*0.6 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateInclusion);


%------------------------ popup for eye dominance
pop_Xeye = uicontrol(fig_h,...
    'Style', 'popupmenu',...
    'String', eyeopts,...
    'Position',[pos(3)*0.2 pos(4)*0.75 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateInclusion);

pop_Yeye = uicontrol(fig_h,...
    'Style','popupmenu',...
    'String', eyeopts,...
    'Position',[pos(3)*0.2 pos(4)*0.55 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateInclusion);

%------------------------ figures to plot when data point click

fig2plot_check(1) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Tuning Curve', ...
    'Position', [pos(3)*0.2 pos(4)*0.10 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(2) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Regression', ...
    'Position', [pos(3)*0.2 pos(4)*0.25 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(3) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'ISI', ...
    'Position', [pos(3)*0.3 pos(4)*0.25 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(4) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'LFP', ...
    'Position', [pos(3)*0.2 pos(4)*0.20 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(5) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Raster', ...
    'Position', [pos(3)*0.3 pos(4)*0.20 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(6) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Wave Form', ...
    'Position', [pos(3)*0.2 pos(4)*0.15 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(7) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Spike Density', ...
    'Position', [pos(3)*0.3 pos(4)*0.15 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);


fig2plot_check(8) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Phase Select.', ...
    'Position', [pos(3)*0.3 pos(4)*0.10 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);

fig2plot_check(9) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'smooth PSTH', ...
    'Position', [pos(3)*0.3 pos(4)*0.30 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);


fig2plot_check(10) = uicontrol(fig_h, ...
    'Style', 'checkbox', ...
    'String', 'Variability', ...
    'Position', [pos(3)*0.2 pos(4)*0.30 pos(3)*0.08 pos(4)*0.05], ...
    'Callback', @UpdateFigures);


%% nested functions

    function exportBar(~, ~)
        % x --> base
        % y --> Serotonin/NaCl
        
        
        figure;
        
        if any(dat.is5HT) && any(~dat.is5HT)
            n_5HT = sum(dat.is5HT);
            n_nacl = sum(~dat.is5HT);
            
            bar([1 2 4 5], [mean(dat.y(dat.is5HT)), mean(dat.x(dat.is5HT)),...
                mean(dat.y(~dat.is5HT)) mean(dat.x(~dat.is5HT))]); hold on;
            errorbar([1 2 4 5], [mean(dat.y(dat.is5HT)), mean(dat.x(dat.is5HT)),...
                mean(dat.y(~dat.is5HT)), mean(dat.x(~dat.is5HT))], ...
                [std(dat.y(dat.is5HT))/sqrt(n_5HT), std(dat.x(dat.is5HT))/sqrt(n_5HT),...
                std(dat.y(~dat.is5HT))/sqrt(n_nacl), std(dat.x(~dat.is5HT))/sqrt(n_nacl)], '.');
            
            set(gca, 'XLim', [0.5 5.5], 'XTick', [1 2 4 5], ...
                'XTickLabel', {'5HT' , '5HT base', ...
                'NaCl', 'NaCl base'});
            ylabel(dat.xlab);
            
            p_wil_5HT = ranksum(dat.x(dat.is5HT), dat.y(dat.is5HT));
            [~, p_ttest_5HT] = ttest(dat.x(dat.is5HT), dat.y(dat.is5HT));
            
            p_wil_nacl = ranksum(dat.x(~dat.is5HT), dat.y(~dat.is5HT));
            [~, p_ttest_nacl] = ttest(dat.x(~dat.is5HT), dat.y(~dat.is5HT));
            
            p_wil_vs = ranksum(dat.y(dat.is5HT), dat.y(~dat.is5HT));
            [~, p_ttest_vs] = ttest2(dat.y(dat.is5HT), dat.y(~dat.is5HT));
            
            title(sprintf(['5HT (n=%1.0f): ranksum p=%1.3f \t ttest p=%1.3f \n' ...
                'NaCl (n=%1.0f): ranksum p=%1.3f \t ttest p=%1.3f \n' ...
                '5HT vs NaCl (scatter y-axis): ranksum p=%1.3f \t ttest2 p=%1.3f \n \n' ...
                '5HT mean %1.2f, mean control %1.2f \t \t NaCl mean %1.2f, mean control %1.2f'], ...
                n_5HT, p_wil_5HT, p_ttest_5HT, ...
                n_nacl, p_wil_nacl, p_ttest_nacl, ...
                p_wil_vs, p_ttest_vs, ...
                mean(dat.y(dat.is5HT)), mean(dat.x(dat.is5HT)),...
                mean(dat.y(~dat.is5HT)), mean(dat.x(~dat.is5HT))));
        else
            n = length(dat.x);
            nsqr = sqrt(n);
            bar(1, mean(dat.y), 'FaceColor', 'r', 'EdgeColor', 'r', 'LineWidth', 2); hold on;
            bar(2, mean(dat.x), 'FaceColor', 'w', 'EdgeColor', 'r'); hold on;
            errorbar([1 2], [mean(dat.y), mean(dat.x)], ...
                [std(dat.y)/nsqr, std(dat.x)/nsqr], 'k.', 'LineWidth', 2); hold on;
            plot([0.5 2.5], [0 0], 'k');
            set(gca, 'XLim', [0.5 2.5], 'XTick', [1 2], 'XTickLabel', {'Serotonin', 'Baseline'});
            ylabel(dat.xlab);
            
            p_wil = ranksum(dat.x, dat.y);
            [~, p_ttest] = ttest(dat.x, dat.y);
            
            if any(dat.is5HT)
                title(sprintf(['5HT (n=%1.0f) mu _{5HT}=%1.3f, med_{5HT}=%1.3f \n'...
                    'mu _{Base}=%1.3f med_{Base}=%1.3f \n'...
                    'ranksum p=%1.3f \t ttest p=%1.3f'], ...
                    n, mean(dat.y), median(dat.y), mean(dat.x), median(dat.x), p_wil, p_ttest));
            else
                title(sprintf('NaCl (n=%1.0f) ranksum p=%1.3f \t ttest p=%1.3f', n, p_wil, p_ttest));
            end
            
        end
        set(gcf, 'UserData', dat);
        hold off;
        
    end

% export plot
    function exportPlot(~, ~)
        
        h2 = figure();
        ax = findobj(fig_h, 'type', 'axes');
        if length(ax) == 1
            ax_new = copyobj(ax, h2, 'legacy');
            ax_new.Position = [ 0.15 0.15 0.7 0.7];
        elseif length(ax) == 3
            ax_new = copyobj(ax, h2, 'legacy');
            
            ax_new(1).Position = [0.15 0.1 0.45 0.55];
            ax_new(2).Position = [0.7 0.1 0.15 0.55];
            ax_new(3).Position = [0.15 0.7 0.45 0.15];
            h2.Position = [643 328 737 537];
        else
           warning('there are too many axes to handle'); 
        end
        
        set(gcf, 'UserData', dat);
    end

% -------------------------------------------------------------------------
% plot according to entered options
    function createPlot(~, eventdata, ~)
        
        
        if (get(popY_h, 'Value') == 1) || (get(popX_h, 'Value') == 1)
            allax = findobj(gcf,'type','axes');
            delete(allax);
        else
            allax = findobj(gcf,'type','axes');
            delete(allax);
            
            fctX = axisopts{get(popX_h, 'Value')-1};
            fctY = axisopts{get(popY_h, 'Value')-1};
            spec.stimx = stimulicond{get(pop_Xspec, 'Value')};
            spec.stimy = stimulicond{get(pop_Yspec, 'Value')};
            
            spec.eyex = eyeopts{get(pop_Xeye, 'Value')};
            spec.eyey = eyeopts{get(pop_Yeye, 'Value')};
            
            %%% special case for mitchel plot
            if ~isempty(strfind(fctY, 'mitchel')) && isempty(strfind(spec.stimy, 'all'))
                UpdateInclusion(editlatency_h, eventdata);
                incl_i =  intersect( incl_i, ...
                    find(cellfun(@(x) strcmp(x,spec.stimy), {expInfo.param1})));
                incl_i =  intersect( incl_i, ...
                    find(~[expInfo.isRC]));
                
%                 incl_i =  intersect( incl_i, ...
%                     find([expInfo.gslope]<1));
                
                UpdatePlotSpec();
                createPlotHelper(get(addHistograms, 'Value') );

                dat.expInfo = expInfo(incl_i);
                set(gcf, 'UserData', dat);
                
                
            %%% all conditions are included
            elseif (strcmp(spec.stimx, 'all stimuli cond') && strcmp(spec.stimy, 'all stimuli cond') ...
                    && strcmp(spec.eyex, 'all') && strcmp(spec.eyey, 'all'))
                UpdateInclusion(editlatency_h, eventdata);
                UpdatePlotSpec();
                createPlotHelper(get(addHistograms, 'Value') );
            
                dat.expInfo = expInfo(incl_i);
                set(gcf, 'UserData', dat);
                
            %%% specific conditions are excluded
            else
                UpdateInclusion(editlatency_h, eventdata);
                dat = createUnitPlot(expInfo(incl_i), fctX, fctY, spec, ...
                    fig2plot, get(addHistograms, 'Value'));
                
                set(gcf, 'UserData', dat);
            
            end
            
            UpdateAxes(fctX, fctY);
                        
        end
        
        if eqAxes.Value;                eqax;        end
        if addUnity.Value;             unity;        end
        if addCross.Value;            crossl;        end
        if addRegress.Value;            regl;        end

    
    end

%%% ------------------- actual plotting
    function createPlotHelper(hist_flag)
        
        fctX = axisopts{get(popX_h, 'Value')-1};
        fctY = axisopts{get(popY_h, 'Value')-1};
        
        dat = evalMU(fctX, fctY, expInfo(incl_i));
        
        % add histograms
        if hist_flag
            pos_hist = [ [0.45 .7 .28 .15];
                [0.78 .18 .12 .45];
                [0.45 .18 .28 .45] ];
        else
            pos_hist(3,:)  = [0.45 .18 .5 .7];
        end
        
        %%% dinstinguish two distributions via logical indexing
        dat.is5HT = getRed(markerface, markerfacecol);
        rx1 = min(dat.x) - min(dat.x)/2;               rx2 = max(dat.x) + max(dat.x)/2;
        ry1 = min(dat.y(1, :)) - min(dat.y(1,:))/2;    ry2 = max(dat.y(1, :)) + max(dat.y(1, :))/2;
        
        if hist_flag
            %%%-------------------------------- histogram x
            subplot(3,3, [1 2]);
            plotHist(dat.x, dat.is5HT);
            set(gca, 'Position', pos_hist(1,:));
            if (rx1 - rx2) ~= 0
                set(gca, 'Xlim', [rx1 rx2], 'xticklabel',[]);
            end
            %%%--------------------------------- histogram y
            subplot(3,3, [6 9])
            plotHist(dat.y, dat.is5HT);
            set(gca, 'Position', pos_hist(2, :));
            if (ry1 - ry2) ~= 0
                set(gca, 'Xlim', [ry1 ry2], 'xticklabel',[]);
            end
            set(gca, 'view',[90 -90]);
            tt = findobj(gca, 'Type', 'text');
            set(tt, 'rotation', -90);
            set(findobj(gca, 'MarkerType', 'v'), 'MarkerType', '^');
            %%%----------------------------------- main plot
            subplot(3,3, [4 5 7 8])
        end
        
        
        
        if ~isempty([dat.err])
            c = 'b';
            for j = 1:size(dat.y, 2)
                errorbar(dat.x, dat.y(:, j), dat.err(:,j), c); hold on;
                c = 'r';
            end
            legend('baseline', '5HT', 'location', 'southeast');
        else
            for j = 1:size(dat.y, 1)
                for i = 1:length(dat.x)
                    scatter(dat.x(i), dat.y(j, i), ...
                        markerAssignment(dat.expInfo(i).param1),...
                        'MarkerFaceColor', markerFaceAssignment( dat.expInfo(i) ),...
                        'MarkerEdgeColor', markeredge(i,:), ...
                        'ButtonDownFcn', {@DataPressed, expInfo(incl_i(i)), ...
                        dat.xlab, dat.ylab, fig2plot} );
                    hold on;
                end
            end
        end
        
        getID(expInfo(incl_i));
        xlabel(dat.xlab); ylabel(dat.ylab);
        hold off;
        set(gca, 'Position', pos_hist(3,:), 'UserData', dat);
        if (rx1 - rx2) ~= 0
%             set(gca, 'xlim',  [rx1 rx2], 'ylim', [ry1 ry2]);
        end
        
        box off
        
        if isempty(strfind(fctX, 'mitchel')) && ~hist_flag
            addTitle(dat.is5HT,dat);
        else
            title(dat.info);
        end
    end

%-------------------------------------------------------------------------
    function UpdateInclusion(check_incl, eventdata)
        incl_i = 1:length(expInfo);
        
        %%% simple (logical) inclusion criteria
%         UpdateHNfiles(strcmp(stimulicond(get(pop_Xspec, 'Value')), 'RC'), 1);

               
        %%% simple numerical inclusion criteria
        UpdateInclusionHelper(1, ...
            ['[expInfo.rsqr_both] ' get(editr2_h, 'String')]);
        UpdateInclusionHelper(strcmp(stimulicond(get(pop_Xspec, 'Value')), 'RC'),...
            ['[expInfo.lat] ' get(editlatency_h, 'String') ' & '...
            '[expInfo.lat_drug] ' get(editlatency_h, 'String') ]);
        UpdateInclusionHelper(1,...
            ['[expInfo.gaussr2] ' get(editr2gauss_h, 'String') ...
            ' & [expInfo.gaussr2_drug] ' get(editr2gauss_h, 'String')]);
        
        % monkeys
        UpdateInclusionHelper(r2.Value, '[expInfo.ismango]');
        UpdateInclusionHelper(r3.Value, '~[expInfo.ismango]');
        
        %%% data critera via popup popC_h
        idx = getCritIdx(expInfo(incl_i), popC_h.String{popC_h.Value});
        incl_i = incl_i(idx);
    end

    function UpdateInclusionHelper(val, cond)
        if val
            eval(['incl_i = intersect( incl_i, find(' cond '));']);
%             fprintf([cond '\n']);
        end
    end

    function UpdateHNfiles(val, all_flag)
        if val
            incl_i = intersect(incl_i, find( cmpFiles(expInfo, 'rc_all')));
        end
    end

%-------------------------------------------------------------------------
%     function UpdatePlotSpec()
%         editMarker(popM_h);
%     end

%     function editMarker(popM_h, eventdata)
%         
%         len = length(expInfo(incl_i));
%         stimcond = {expInfo(incl_i).param1};
%         
%         marker = repmat({'^'}, len, 1);
%         
%         
%         if get(popM_h, 'Value') == 2
%             for kk = 1:len
%                 marker{kk} = markerAssignment(stimcond{kk});
%             end
%         end
%     end

%--------------------------------------------------------------------------
    function UpdateAxes(fctX, fctY)
        
        axrg = [0.125 8];
        allax = findobj(gcf, 'Type', 'axes');
        
        % X AXES
        if (strcmp(fctX, 'gain change') || ~isempty(strfind(fctX, 'fano')))
            
            % log scaled axes
            if length(allax) > 1
                plotHist(dat.x, dat.is5HT, allax(3), 'log');
                set(allax(3), 'xlim', axrg, 'XScale','log', 'XTick', [0.25 1 4]);
            end
            set(allax(1), 'xlim', axrg, 'XScale','log', 'XTick', [0.25 1 4]);
        end
        
        % Y AXES
        if (strcmp(fctY, 'gain change') || ...
                (~isempty(strfind(fctY, 'fano')) && isempty(strfind(fctY, 'diff'))))
            
            if length(allax) >1
                plotHist(dat.y, dat.is5HT, allax(2), 'log');
                set(allax(2), 'XScale','log', 'XTick', [0.25 1 4], 'xlim', axrg);
            end
            set(allax(1), 'YScale','log', 'YTick', [0.25 1 4], 'ylim', axrg);
        
        end
    end

%--------------------------------------------------------------------------
    function UpdateFigures(~, eventdata, ~)
        fig2plot = vertcat({fig2plot_check.String});
        fig2plot = fig2plot([fig2plot_check.Value]==1);
    end




end



%--------------------------------------------------------------------------
    function CloseAll(~, eventdata, ~)
        close all
    end

    
function my_closereq(src,callbackdata)
% Close request function 
% to display a question dialog box 
   selection = questdlg('Close This Figure?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         delete(gcf)
      case 'No'
      return 
   end
end
