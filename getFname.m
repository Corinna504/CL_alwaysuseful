function fname = getFname(ex)

if isfield(ex.Header, 'Headers')
    fname = ex.Header.Headers(1).fileName;
elseif isfield(ex.Header, 'Sort')
    fname = ex.Header.Sort.exFileName;
else
    fname = ex.Header.fileName;
end