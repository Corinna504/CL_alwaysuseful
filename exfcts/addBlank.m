% 
% add...
% - ...blank value 
% - ...tolerance information, if vals do not exactly fit actual parameter
%   settings
% 
% @author Corinna Lorenz
% @created 22.09.2015
% @lastchanged 22.09.2015


% compensate for imprecise values
% rnd = num2cell(round([ex.Trials.(ex.exp.e1.type)] *1e4) *1e-4);
% [ex.Trials.(ex.exp.e1.type)] =  deal(rnd{:});


% all occuring values
allvals = unique([ex.Trials.(ex.exp.e1.type)]); 


% add blank value
if isfield(ex,'exp') && isfield(ex.exp,'e1')
    ex.exp.e1.blank = unique([ex.Trials([ex.Trials.st]==0).(ex.exp.e1.type)]);
    ex.exp.e1.blankname = 'blank'; 
else
    disp('no exp');
end


% add blank and tolerance
if length(ex.exp.e1.blank) > 1
    if length(ex.exp.e1.blank) > 3
        disp('no no no! ther are still a lot of non-matching values');
    else
        [ex.Trials([ex.Trials.st]==0).(ex.exp.e1.type)] = deal(ex.exp.e1.blank(1));
        ex.exp.e1.blank = ex.exp.e1.blank(1);
    end
elseif isempty(ex.exp.e1.blank) 
     ex.exp.e1.blank = [];
     ex.exp.e1.blankname = [];
end


% add e2 dummy
if isfield(ex,'exp') && ~isfield(ex.exp,'e2')
    ex.exp.e2.type  = 'me';
    ex.exp.e2.vals  = unique([ex.Trials.me]);
end

clearvars allvals;