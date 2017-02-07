function exinfo = addNumInExp( exinfo )
% loads the spike sorting tables and reads out the number of 5HT
% experiments before the present one
%
%  
% 
% @CL February 2, 2017


% load spike sorting files
A = readSpikingTable('Kaki_SpikeSortingFile.csv');
B = readSpikingTable('Mango_SpikeSortingFile.csv');
sorting.matfilename = [{B.matfilename}'; {A.matfilename}'];
sorting.iontophoresis = [{B.iontophoresis}'; {A.iontophoresis}'];


for i = 1:length(exinfo)
   
       fprintf('WORKING ON ROW %1i, file %1.1f \n', i, exinfo(i).id);
    [exinfo(i).dn, exinfo(i).dt, exinfo(i).dt_cum] = ...
        getDeltaNexp(exinfo(i), sorting);
    
end


end

%%
function [dn, dt, dt_cum] = getDeltaNexp(exinfo, sorting)
% for each filename fname look for the according entry in the sorting file
% if it is a concatenated file, take the average sorting quality


fname = exinfo.fname_drug;
id = floor(exinfo.id); % #unit
monkey = exinfo.monkey; % animal name
drugname = exinfo.drugname; % 5HT or NaCl

if isempty(strfind(fname, 'all.grating'))
    [dn, dt, dt_cum] = getDeltaNexpHelper(fname, id, monkey, sorting, drugname);
else
    % loop through all original experiments, if it is a concatenated file
    load(fname);
    fname_list = getFnames(ex);
    for kk = 1:length(fname_list)
        [dn_list(kk), dt_list(kk), dt_cum(kk)] = ...
            getDeltaNexpHelper(fname_list{kk}, id, monkey, sorting, drugname);
    end
    dn = min(dn_list);
    dt = min(dt_list);
    dt_cum = min(dt_cum);
    
end

end


function [dn, dt, dt_cum] = getDeltaNexpHelper(fname, id, monkey, sorting, drugname)
% reads out the number of drug experiments dn and the time passed between
% first drug experiment and the current experiment dt

% get all indices indicating this unit's experiments 
idx_all = findIdxMatchingID(sorting.matfilename, id, monkey);

% use only the drug applied experiments
idx_all = idx_all( ~cellfun(@isempty, strfind(sorting.iontophoresis(idx_all), drugname)) ); 


% find the index of this exact experiment under observation
idx_f = findIdxMatchingFname(sorting.matfilename, fname, monkey);


%%% compute the number of drug experiments between the session start and
%%% the current experiment
% for this we only need the difference between the indices accounting 
dn = sum( idx_all < idx_f );



%%% compute the time between first 5HT application and the current
%%% experiment
if idx_all(1) == idx_f
    dt = 0; % if this is the first experiment
    dt_cum = 0;
else
    %%% the absolute different between the first drug experiment and the current
    %%% one
    % first drug experiment
    ex1_fname = fulfillfdir(sorting.matfilename{idx_all(1)}, monkey, id, drugname);
    load( ex1_fname );
    t1 = getTstart(ex);
        
    
    % current drug experiment
    fname = strrep(fname, 'J:', 'Z:');
    if strcmp(fname(1:2), 'ma')
        fname = fullfile('Z:\data\mango\', getStringID(id, monkey), fname);
    end
    
    load(fname)
    t2 = getTstart(ex);
    
    % difference in seconds
    dt = (t2 - t1)/10 ;
        
    
    %%% the cummulative time of drug application before the start of this
    %%% exeriment
    idx_all = idx_all(idx_all<idx_f);
    dt_cum = 0;
    for kk =1:length(idx_all)
        ex_fname = fulfillfdir(sorting.matfilename{idx_all(kk)}, monkey, id, drugname);
        load( ex_fname );
        [t_strt, t_end]  = getTstart(ex);
        
        dt_cum = dt_cum + (t_end - t_strt);
    end
    
end

end

%%
function fname = fulfillfdir(fname_short, monkey, id, drugname)
% this function computes the correct directory and the filename and returns
% the concatination of both, i.e. the ful filename.

% file directory
if strcmp(monkey , 'ka')
    fdir = ['Z:\data\kaki\' getStringID(id) '\'];
else
    fdir = ['Z:\data\mango\' getStringID(id) '\'];
end

% file name
fname_short = strrep(fname_short, '.mat', '');
[~, i_end] = regexp(fname_short, getStringID(id, monkey));
fname_ful = [fname_short(1:i_end+1) 'c1_sortLH_' fname_short(i_end+2:end) '_' drugname '.mat'];

% concatenate directory and filename
fname = fullfile(fdir, fname_ful);

if ~exist(fname, 'file')
    fname_ful = [fname_short(1:8) 'c1_sortHN_' fname_short(9:end) '_' drugname '.mat'];
    fname = fullfile(fdir, fname_ful);
end
if ~exist(fname, 'file')
    fname_ful = [fname_short(1:8) 'c1_sortLH_' fname_short(9:end) '_' drugname 'Ket.mat'];
    fname = fullfile(fdir, fname_ful);
end
if ~exist(fname, 'file')
    fname_ful = [fname_short(1:8) 'c1_sortLH_' fname_short(9:end) '_' drugname 'SB.mat'];
    fname = fullfile(fdir, fname_ful);
end


if ~exist(fname, 'file')
    fname
    error('this file does not exist as it is');
end


end


%% 
function [t_strt, t_end] = getTstart(ex)

% if isfield(ex, 'Header')
%     if isfield(ex.Header, 'fileID')
%         t = ex.Header.fileID;
%     elseif isfield(ex.Header, 'Sort')
%         t = ex.Header.Sort.DateTime;
%     end
% else
%     disp('search for alternatives');
% end
t_strt = ex.Trials(1).TrialStart;
t_end = ex.Trials(end).TrialEnd;

% t = datestr(t);
% t = datevec(t);

end