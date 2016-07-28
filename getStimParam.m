function [ param, vals] = getStimParam( ex )
% getStimParam returns the one stimulus that was modulated during the
% experiment, i.e. that is in the ex.Trials file

if isfield(ex.Trials, 'or')
    param = 'or';
    vals = unique([ex.Trials.or]);
elseif isfield(ex.Trials, 'co')
    param = 'co';
    vals = unique([ex.Trials.co]);
elseif isfield(ex.Trials, 'sz')
    param = 'sz';
    vals = unique([ex.Trials.sz]);
elseif isfield(ex.Trials, 'sf')
    param = 'sf';
    vals = unique([ex.Trials.sf]);
end

end

