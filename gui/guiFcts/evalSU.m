function dat = evalSU(fnamecell, fname_ind, fctname, clustername, expInfo_i, expInfo_all)
%% evaluates the input and assigns the correct functions
% returns data struct that is also saved in the figure components.
% Use get(gcf,'UserData') to get access via the command window.
%

%%--------------------------------------------------------------- load file
if strcmp(clustername, 'c1')
    
    if isempty(strfind(fnamecell{1}, '5HT')) && ...
            isempty(strfind(fnamecell{1}, 'NaCl'))
        [ex_drug, drugname] = loadCluster(fnamecell{2});
        ex = loadCluster(fnamecell{1});
    else
        [ex_drug, drugname] = loadCluster(fnamecell{1});
        ex = loadCluster(fnamecell{2});
    end
    
    
elseif strcmp(clustername, 'c1/c0')
    ex1 = loadCluster(fnamecell{1});
    
    if strfind(fnamecell{1}, 'c1')
        ex0 = loadCluster(strrep(fnamecell{1}, 'c1', 'c0'));
    else
        ex0 = loadCluster(strrep(fnamecell{1}, 'c2', 'c0'));
    end
    
elseif strcmp(clustername, 'lfp')
    if strfind(fnamecell{1}, 'c1')
        fnamecell = {strrep(fnamecell{1}, 'c1', 'lfp')};
    else
        fnamecell = {strrep(fnamecell{1}, 'c2', 'lfp')};
    end
    
    ex = loadCluster(fnamecell{1});
    
end


currUnit = expInfo_all( strcmp({expInfo_all.fname}, fnamecell{1}) ...
    | strcmp({expInfo_all.fname_drug}, fnamecell{1}) ).id;

% dat.h = gcf;


%%----------------------------------------------------------- find function
switch fctname
    
    case 'compare TC'
        
        dat_base  = fctTuningCurve(ex);
        dat_drug  = fctTuningCurve(ex_drug);
        
        iter = size(dat_base.errbar, 2);
        coldef = lines(iter);

        %%% plot
        
        for i = 1:iter
            
            errorbar(1:length(dat_base.xticklab), ...
                cellfun(@mean, dat_base.errbar(:, i)), ...
                cellfun(@std, dat_base.errbar(:, i)), 'Color', coldef(i,:)); hold on;
            
        end
        
        legend(dat_base.leg);
        
        
        for i = 1:iter
            errorbar(1:length(dat_base.xticklab), ...
                cellfun(@mean, dat_drug.errbar(:, i)), ...
                cellfun(@std, dat_drug.errbar(:, i)), ...
                'Color', coldef(i,:), ...
                'LineStyle', ':' ); 
        
        
            for kk = 1:size(dat_drug.errbar, 1)
                text(kk, mean(dat_base.errbar{kk, i}),...
                    num2str(length(dat_base.errbar{kk, i})),...
                    'Color', coldef(i,:));
                text(kk, mean(dat_drug.errbar{kk, i}),...
                    num2str(length(dat_drug.errbar{kk, i})),...
                    'Color', coldef(i,:));
            end
        
        
        end
        
        
        
        
        hold off;
        
        
        set(gca, 'XTick', 1:length(dat_base.xticklab), 'XTickLabel', dat_base.xticklab);
        xlim([0, length(dat_base.xticklab)+1]); xlabel(dat_base.xlab), ylabel(dat_base.ylab);
        
        dat.info = 'dat.base, dat.drug';
        dat.base = dat_base;
        dat.drug = dat_drug;
        
        
    case 'tuning curve'
        
        
        % load again to get the correct file (= first file)
        ex = loadCluster(fnamecell{1});
        
        %%% x, y, errorbar, ...
        dat    = fctTuningCurve(ex);
        
        %%% plot
        coldef = lines(3);
        
        
        for i = 1:size(dat.errbar, 2)
            errorbar(1:length(dat.xticklab), ...
                cellfun(@mean, dat.errbar(:, i)), ...
                cellfun(@std, dat.errbar(:, i)), 'Color', coldef(i,:)); hold on;
            
            
            for kk = 1:length(dat.errbar(:, i))
                text(kk, mean(dat.errbar{kk, i}),...
                    num2str(length(dat.errbar{kk, i})),...
                    'Color',  coldef(i,:));
            end
        end
        hold off;
        
        legend(dat.leg(:));
        set(gca, 'XTick', 1:length(dat.xticklab), 'XTickLabel', dat.xticklab);
        xlim([0, length(dat.xticklab)+1]); xlabel(dat.xlab), ylabel(dat.ylab);
        
        %%% info
        dat.info = sprintf(' dat.errbar ');
        
    case 'gain change'
        
        %%% x
        rsigdat  = fctSignal(ex);
        dat.leg  = rsigdat.leg;
        dat.me   = rsigdat.me;
        dat.x    = rsigdat.mu;
        dat.xlab = 'base';
        
        %%% y
        rsigdat_drug = fctSignal(ex_drug);
        dat.y    = rsigdat_drug.mu;
        dat.ylab = drugname;
        
        
        if size(dat.x) ~= size(dat.y)
            
        else
            
            iter = size(dat.x, 2);
            coldef = lines(iter);
            
            max_x = max(max(dat.x)); max_y = max(max(dat.y));
            
            for i = 1:iter
                [dat.gain(i), dat.yoff(i), ~, ~, ~] = fitGchange(dat.x(:,i), dat.y(:,i));
                %%% plot
                plot([0; dat.x(:,i); max_x], [0; dat.x(:,i); max_x] .*dat.gain(i) + dat.yoff(i), 'Color', coldef(i,:));  hold on;
            end
            
            legend(dat.leg);
            for i = 1:iter
                
                scatter(dat.x(:,i), dat.y(:,i), '.', 'MarkerEdgeColor', coldef(i, :)); hold on;
            end
            
            
            %%% unity line
            max_ = max(max_x, max_y);
            plot([0 max_] , [0 max_], '--k');
            xlabel(dat.xlab); ylabel(dat.ylab); hold off;
            
            %%% info
            formatspec = ' gain = \t %0.2f \t %0.2f \t %0.2f \n yoff = \t %0.2f \t %0.2f \t %0.2f ';
            dat.info = sprintf(formatspec, dat.gain, dat.yoff);
        end
        
    case 'noise correlation'
        
        if ~exist('ex0', 'var')
            dat.info = 'use c1/c0';
        else
            
            %%% x
            dat.xlab    = 'spike rate c0';
            rscdat0     = fctNoise(ex0, 1);
            dat.me      = rscdat0.me;
            dat.leg     = rscdat0.leg;
            dat.x       = rscdat0.znorm;
            
            %%% y
            dat.ylab    = 'spike rate c1';
            rscdat1     = fctNoise(ex1, 1);
            dat.y       = rscdat1.znorm;
            
            
            %%% plot
            iter = size(dat.x, 2);
            coldef = lines(iter);
            for i = 1:iter
                [dat.r_sc(i), dat.p(i)] = corr(dat.x(:,i), dat.y(:,i), 'rows', 'complete');
                scatter(dat.x(:,i), dat.y(:,i), '.', 'MarkerEdgeColor', coldef(i, :)); hold on;
            end
            xlabel(dat.xlab); ylabel(dat.ylab); legend(dat.leg);
            xlim([-3, 3]); ylim([-3, 3]); hold off;
            
            %%% info
            formatspec = ' r_sc = \t %0.2f \t %0.2f \t %0.2f \n p = \t %0.2f \t %0.2f \t %0.2f ';
            dat.info = sprintf(formatspec, dat.r_sc, dat.p);
        end
        
    case 'signal correlation'
        
        if ~exist('ex0', 'var')
            dat.info = 'use c1/c0';
        else
            
            %%% x
            dat.xlab    = 'mean spike rates c0';
            rsigdat0    = fctSignal(ex0, 1);
            dat.x       = rsigdat0.mu;
            dat.leg     = rsigdat0.leg;
            
            %%% y
            dat.ylab    = 'mean spike rates c1';
            rsigdat1    = fctSignal(ex1, 1);
            dat.y       = rsigdat1.mu;
            
            %%% plot
            iter = size(dat.x, 2);
            coldef = lines(iter);
            for i = 1:iter
                [dat.r_sig(i), dat.p(i)] = corr(dat.x(:,i), dat.y(:,i), 'rows', 'complete');
                scatter(dat.x(:,i), dat.y(:,i), 'MarkerEdgeColor', coldef(i, :)); hold on;
            end
            xlabel(dat.xlab); ylabel(dat.ylab); legend(dat.leg); hold off;
            
            %%% info
            formatspec = ' r_sig = \t %0.2f \t %0.2f \t %0.2f \n p = \t %0.2f \t %0.2f \t %0.2f ';
            dat.info = sprintf(formatspec, dat.r_sig, dat.p);
            
        end
        
    case 'fano factor (Mitchel)'
                
        dat = fctMitchel(expInfo_i);
        
    case 'fano factor (Churchl)'
        
    case 'fano factor (CL)'
        
    case 'lfp (frequ domain)'
        
        
        frequ = fctFrequ(ex, 'bandstop');
        dat.info = 'needs to be done';
        
    case 'lfp (time domain)'
        dat.info = 'needs to be done';
        
    case 'waveform'
        
        %%% base % drug
        dat = fctPlotWaveWidth(ex.Trials, ex_drug.Trials);
        
    case 'pupil size all'
        
        ex = loadCluster(fnamecell{1});
        dat = fctPupilSize2(ex);
        if ~strcmp(dat.info, 'no binocular trials')
            plot(1:length(dat.rsz), dat.rsz, 'Color', [0.8 0.8 0.8]); hold on;
            plot(dat.v3-dat.med, 'k'); hold off;
            xlim([0, length(dat.t)] );
        end
        
    case 'pupil size onset'
        ex = loadCluster(fnamecell{1}, 1);

        dat = fctPupilSizeTrial(ex);
        xlabel('time (stimulus onset = 0)');
        
    case 'pupil size change'
         ex = loadCluster(fnamecell{1}, 1);

        dat = fctPupilSizeTrialMN(ex);
        xlabel('time (stimulus onset = 0)');
        ylabel('change in pupil size');
        title('red is mean trajectory, blue changes to mean');
        
    case 'time course of spike rate'
        dat = fctPlotTimeCourseUnit(expInfo_all([expInfo_all.id]==currUnit), 'spike rate');
        
    case 'time course of gain change'
        dat = fctPlotTimeCourseUnit(expInfo_all([expInfo_all.id]==currUnit), 'gain change');
        
    case 'time course of wave width'
        dat = fctPlotTimeCourseUnit(expInfo_all([expInfo_all.id]==currUnit), 'wave width');
        
    case 'time course of rsc'
        dat = fctPlotTimeCourseUnit(expInfo_all([expInfo_all.id]==currUnit), 'rsc');
        
        
end

%%% save dat in figure handle
dat.fname = fnamecell;
set(gcf, 'UserData', dat);


end

