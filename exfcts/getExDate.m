function date = getExDate( ex )
%GETEXDATA extracts date stamp from header
% 

if isfield(ex.Header, 'fileID')
    date = datenum([ex.Header.fileID]);
elseif isfield(ex, 'fileID')
    date = datenum([ex.fileID]);
else
    date = datenum([ex.Header.Headers(1).fileID]);
end


end

