function [ex, argout] = evalSingleEx( exinfo, fname, varargin)
%evalSingleEx evaluates all operations done on one single ex file


if exinfo.isRC
    [ex, argout] = evalSingleRC(exinfo, fname, varargin{:});
else
    [ex, argout] = evalSingleDG(exinfo, fname, varargin{:});
end


end



