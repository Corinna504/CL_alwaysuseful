
function Trials = getPartialTrials(Trials)

l = length(Trials);
lhalf = ceil(l/2);
% fprintf('#trials n=%1.0f, 1st half: n=%1.0f \n\n', l, lhalf);
Trials = Trials(lhalf:end);



if l == 1
    l = length(Trials.param);
    lhalf = ceil(l/2);
    Trials.param = Trials.param(lhalf:end);

end

end