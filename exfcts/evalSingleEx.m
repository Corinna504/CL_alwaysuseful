function [ex, argout] = evalSingleEx( exinfo, fname )
%evalSingleEx evaluates all operations done on one single ex file


if exinfo.isRC
    [ex, argout] = evalSingleRC(exinfo, fname);
else
    [ex, argout] = evalSingleDG(exinfo, fname);
end


end



