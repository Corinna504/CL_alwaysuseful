function filetxt = file2txtgui( varargin )
%dosegui lets you compare ex files from same unit with different dose

fdir0 = 'D:\data\kaki';

inp = 1;
while inp<=length(varargin)
    switch varargin{inp}
        case 'fdir0'
            fdir0 = varargin{inp+1};
    end
    inp = inp+1;
end



global h_fdir;
global h_files;

filetxt = {};
filename = 'file.txt';


h = figure('Position', [500 500 800 400]);
% --------------------- data directory

h_fdir = uicontrol(h, 'Style', 'edit', ...
    'String', fdir0,...
    'Position', [20 350 400 20], ...
    'Enable', 'Inactive', ...
    'ButtonDownFcn', @updateFolder);

% --------------------- all files in the directory
h_files = uicontrol(h, ....
    'Style', 'listbox', ...
    'String', '', ...
    'Position', [20 140 400 200]);

% --------------------- all files in the textfile
txt_files = uicontrol(h, ....
    'Style', 'listbox', ...
    'String', filetxt, ...
    'Position', [450 140 300 200]);


% --------------------- check TC
uicontrol('Style', 'pushbutton', ...
    'String', 'Tuning Curve',...
    'Position', [200 100 100 20], ...
    'Callback', @callTC);


% --------------------- check mean firing rate across files
uicontrol('Style', 'pushbutton', ...
    'String', 'Plot Time Course',...
    'Position', [300 100 100 20], ...
    'Callback', @callDosePlot);


% --------------------- add to text file
uicontrol('Style', 'pushbutton', ...
    'String', 'Add to txt',...
    'Position', [100 100 100 20], ...
    'Callback', @add2txt);


% --------------------- remove from text file
uicontrol('Style', 'pushbutton', ...
    'String', 'Remove from txt',...
    'Position', [650 100 100 20], ...
    'Callback', @rmfile);

% --------------------- save text file
uicontrol('Style', 'pushbutton', ...
    'String', 'Save',...
    'Position', [670 50 80 20], ...
    'Callback', @savetxt);

uicontrol('Style', 'edit', ...
    'String', 'Name',...
    'Position', [500 50 150 20], ...
    'Callback', @editfilename);



%% update folderfiles
    function updateFolder(~,~)
        
        fdir = uigetdir(get(h_fdir, 'String'));
        
        if fdir~=0
            fname = dir(fdir);
            fname = fname(...
                cellfun(@(x) (~isempty(strfind(x, 'c1')) || ...
                ~isempty(strfind(x, 'c2'))) && ...
                isempty(strfind(x, 'Pos')) && ...
                isempty(strfind(x, 'sortKK'))&& ...
                isempty(strfind(x, 'XX')), ...
                {fname.name}));
            
            set(h_files, 'Value', 1);
            set(h_files, 'String', {fname.name});
            set(h_files, 'Max', length(fname));
            set(h_fdir, 'String', fdir);
        end
    end

    function callDosePlot(~,~)
        
        sz = 50;
        fdir = get(h_fdir, 'String');
        
        figure('Name', fdir);
        fnames = get(h_files, 'String');
        val = get(h_files, 'Value');
        
        dose = nan(length(val), 1);
        id = nan(length(val), 1);
        stim = cell(length(val), 1);
        meanspk = nan(length(val), 1);
        for i = 1:length(val)
            [temp, dose(i), volt(i), id(i), stim{i}] = PlotTC(fdir,  fnames{val(i)}, ...
                'plot', false);
            
            [~, max_i] = max(mean(temp, 2));
            meanspk(i) = nanmean(temp(max_i, :));
        end
        
        
        [~, idx] = sort(id);
        dose = dose./2;
        
        for j2 = 1:length(val)
            i = idx(j2);
            j = id(i)-min(id);
            if ~isempty(strfind(fnames{val(i)}, '5HTSB'))
                scatter(j, meanspk(i), sz*dose(i), 'o', 'm', 'filled', ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            elseif ~isempty(strfind(fnames{val(i)}, '5HTKet'))
                scatter(j, meanspk(i), sz*dose(i), 'o', 'filled', ...
                    'MarkerFaceColor',[1 .5 0],  ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            elseif ~isempty(strfind(fnames{val(i)}, 'Ket'))
                scatter(j, meanspk(i), sz*dose(i), 'd', 'filled', ...
                    'MarkerFaceColor',[1 .5 0], ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            elseif ~isempty(strfind(fnames{val(i)}, 'SB'))
                scatter(j, meanspk(i), sz*dose(i), 'd', 'm', 'filled', ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            elseif ~isempty(strfind(fnames{val(i)}, '5HT'))
                scatter(j, meanspk(i), sz*dose(i), 'o', 'r', ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            elseif ~isempty(strfind(fnames{val(i)}, 'NaCl'))
                scatter(j, meanspk(i), sz*dose(i), 'd', 'filled', ...
                    'MarkerFaceColor', [.8 .8 .8], ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            else
                scatter(j, meanspk(i), sz, 'o', 'r', 'filled', ...
                    'ButtonDownFcn', {@PlotTC_helper, fdir, fnames{val(i)}} );
            end
            hold on;
            text(j, meanspk(i), [stim{i} ',' num2str(volt(i))]);
        end
        
        
        
        %         plot(get(gca, 'xlim'), [0 0], 'Color', [0.6 0.6 0.6]);
        title( sprintf(['baseline: filles o, 5HT: white o, ' ...
            'NaCl: grey diamond \n SB: magenta, Ket:orange']));
        ylabel('mean spk resp');
    end

    function callTC(~,~)
        
        fdir = get(h_fdir, 'String');
        fnames = get(h_files, 'String');
        val = get(h_files, 'Value');
        if length(val) > 1
            c = lines(length(val));
            figure;
            p = subplot(3,1,[1 2]);
            dose = nan(length(val), 1); volt = nan(length(val), 1); 
            timeofrec = dose;
            exname = cell(length(val), 1);
            
            
            for i = 1:length(val)
                [~, dose(i), volt(i),timeofrec(i), ~] = PlotTC(fdir, fnames{val(i)}); h =gcf;
                ax = findobj(gcf, 'Type', 'Axes');
                set(findobj(ax.Children, 'Type', 'ErrorBar'), 'Color', c(i, :));
                
                copyobj(ax.Children, p);
                exname{i} = get(h, 'Name');
                param = ax.XLabel.String;
                delete(h);
            end
                        
            xlabel(param);
            
            subplot(3,1,3);
            ylim([0 length(val)]);
            for i = 1:length(val)
                str = sprintf([exname{i} ' dose: %1.0f nA, %1.1f volt' ],...
                    dose(i), volt(i));
                text(0, length(val)-i, str, 'Color', c(i,:), 'FontSize', 10);
            end
            axis off            
            clear i exname ax val fnames fdir p c
        else
            PlotTC(fdir, fnames{val});
        end
    end

    function add2txt(~, ~)
        
        fdir = [get(h_fdir, 'String') '\'];
        exnames = get(h_files, 'String');
        val = get(h_files, 'Value');
        
        filetxt = [filetxt; strcat(fdir, exnames(val))];
        filetxt = unique(filetxt);
        
        
        txt_files.String = filetxt;
        txt_files.Value = 1;
        
        
        
        fileID = fopen('temp.txt',  'wt');
        fprintf(fileID, '%s\n', filetxt{:});
        fclose(fileID);
    end

    function savetxt(~, ~)
        fileID = fopen(filename,  'wt');
        fprintf(fileID, '%s\n', filetxt{:});
        fclose(fileID);
    end

    function rmfile(~, ~)
        
        fnames = get(txt_files, 'String');
        
        if length(fnames) <= 1
            set(txt_files, 'String', '')
        else
            ind = ones(length(fnames),1);
            ind(get(txt_files, 'Value')) = 0;
            ind = logical(ind);
            
            set(txt_files, 'Value', sum(ind));
            fnames = fnames(ind);
            set(txt_files, 'String', fnames)
        end
        filetxt = fnames;
        
        
        fileID = fopen('temp.txt',  'wt');
        fprintf(fileID, '%s\n', filetxt{:});
        fclose(fileID);
        
    end

    function editfilename(src, ~)
        filename = [src.String '.txt'];
    end
end


function PlotTC_helper(~,~,fdir, fname)
PlotTC(fdir, fname);
end
