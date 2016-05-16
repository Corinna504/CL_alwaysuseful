function dat = evalXY(fnames, fctx, fcty)
%% evaluates the input and assigns the correct functions to plot y and x
% returns data struct that is also saved in the figure components.
% Use get(gcf,'UserData') to get access via the command window.
%



tmpx  = getAX(fnames, fctx);
dat.x = tmpx.vals; dat.me = tmpx.me; dat.xlab = tmpx.lab;
tmpy  = getAX(fnames, fcty);
dat.y = tmpy.vals; dat.ylab = tmpy.lab;



if size(dat.x,1) ~=size(dat.y,1)
warning('analysis produces x and y with different sizes');
else
    
    for i = 1:length(dat.x)
        
        scatter(dat.x(i,1), dat.y(i,1), 'MarkerEdgeColor', [0.1 0.1 0.1]); hold on;
        
        xlabel(dat.xlab);
        ylabel(dat.ylab);
    end
    
end

hold off;

end




function ax = getAX(fnames, fctname)


fnames_drug = fnames( cellfun(@isempty, (strfind(fnames, '5HT'))) & ...
    cellfun(@isempty, (strfind(fnames, 'NaCl'))));
fnames_base = fnames( ~cellfun(@isempty, (strfind(fnames, '5HT'))) | ...
    ~cellfun(@isempty, (strfind(fnames, 'NaCl'))));


%%----------------------------------------------------------- find function
switch fctname
    
    case 'gain change'
        
        for i = 1:10 %length(fnames_drug)
            ex      = loadCluster(fnames_drug{i});
            base    = fctSignal(ex);
            ex2     = loadCluster(fnames_base{i}); 
            drug    = fctSignal(ex2);
            
            for j = 1:size(base.mu, 2)
                [ax.vals(i, j), ~, ~, ~, ax.r2(i, j)] = fitGchange(base.mu(:,j), drug.mu(:,j));
            end
            
            disp([ 'processing ' num2str(i)]);
            
        end
        
        ax.lab = 'gain change';
        ax.me  = base.me;
        
    case 'additive change'
        
        for i = 1:10 % length(fnames_drug)/4
            
            ex      = loadCluster(fnames_drug{i});
            base    = fctSignal(ex);
            ex2     = loadCluster(fnames_base{i});
            drug    = fctSignal(ex2);
            
            for j = 1:size(base.mu, 2)
                [~, ax.vals(i, j), ~, ~, ax.r2(i, j)] = fitGchange(base.mu(:,j), drug.mu(:,j));
            end
            
            disp([ 'processing ' num2str(i)]);
            
        end
        
        ax.lab = 'additive change';
        ax.me  = base.me;

                
    case 'noise correlation'
        
        for i = 1:length(fnames)
 
            % c1 file
            ex1 = loadCluster(fnames{i});
            c1  = fctNoise(ex1);
            clearvars ex;
            
            % c0 file
            if exist(strrep(fnames{i}, 'c1', 'co'), 'file')
                ex0 = loadCluster(strrep(fnames{i}, 'c1', 'co'));
            else
                ex0 = loadCluster(strrep(fnames{i}, 'c2', 'co'));
            end
            c0 = fctNoise(ex0);
            
            % correlation
            for j = 1:size(c1.znorm, 2)
                ax.vals(i, j) = corr(c0.znorm(:,j),c1.znorm(:,j), 'rows', 'complete');
            end
            
        end
        
        ax.lab = 'r_{sc}';
        ax.me  = c1.me;

        
    case 'signal correlation'
        
        for i=1:lenght(fnames)
            
            % c1 file
            ex1 = loadCluster(fnames{i});
            c1  = fctSignal(ex1);
            clearvars ex;
            
            % c0 file
            if exist(strrep(fnames{i}, 'c1', 'co'), 'file')
                ex0 = loadCluster(strrep(fnames{i}, 'c1', 'co'));
            else
                ex0 = loadCluster(strrep(fnames{i}, 'c2', 'co'));
            end
            c0 = fctSignal(ex0);
            
                        
            for j = 1:size(c1.mu, 2)
                ax.vals(i, j) = corr(c0.mu(:,1), c1.mu(:,i), 'rows', 'complete');
            end
            
        end
        
        ax.lab    = 'r_{sig}';
        ax.me  = c1.me;

    case 'fano factor'
        
    case 'waveform'
        
        
        for i = 1:2:length(fnames)

            ex      = loadCluster(fnames{i});
            ex_drug = loadCluster(fnames{i+1});
             
            %%% base % drug
            if isfield(ex.Trials,'Waves') && isfield(ex_drug.Trials,'Waves')
                tmp  = vertcat([ex.Trials.Waves]);
                tmp2 = vertcat([ex_drug.Trials.Waves]);

                [ax(ceil(i/2)).vals, ~, ~] = fctWaveWdt([tmp; tmp2]);

            else
                ax.vals = [];
                ax.info = 'no waves in this file';
            end
        end
        
        ax.lab = 'wave width';
        
end
end