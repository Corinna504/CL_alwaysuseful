function [lfpbase, lfpdrug] = LoadLFPfile( dat )
% load the lfp data and reduce the trials to only such with highest
% contrast

lfpbase = LoadLFPHelper(dat.fname, dat);
lfpdrug = LoadLFPHelper(dat.fname_drug, dat);
  
end


function ex = LoadLFPHelper(fname, dat)


% rename file name for lfp file
if dat.isc2
    LFPname = strrep(fname, 'c2', 'lfp');
    
else
    LFPname = strrep(fname, 'c1', 'lfp');
end

% load LFP ex files
load(LFPname); 

isCorTrial = ([ex.Trials.Reward]==1); % only rewarded trials
isOcul = ([ex.Trials.me]==dat.ocul); % match ocularity

% use only rewarded trials with matching ocularity and full contrast
% stimuli
ex.Trials=ex.Trials(isCorTrial & isOcul);

% call frequency analysis (filtering and interpolating)
ex=frequAnalysis(ex);
end
