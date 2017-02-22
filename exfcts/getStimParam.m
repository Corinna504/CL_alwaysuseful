function [ param, vals] = getStimParam( ex )
% getStimParam returns the one stimulus that was modulated during the
% experiment, i.e. that is in the ex.Trials file


try
param = ex.exp.e1.type;
vals = unique([ex.Trials.(param)]);
catch
    warning('watch this..')
end

end

