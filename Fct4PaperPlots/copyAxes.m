function stats = copyAxes(s, fname)

h = openfig(fname, 'invisible');

% save the statistics
if nargout ==1
    dat = h.UserData;
    stats = writeStats2File(dat.Stats, fname);
end

% copy the axes
ax = findobj(h, 'type', 'axes');

if length(ax)>1
    copyobj(ax(2).Children, s); delete(h);
else
    copyobj(ax(1).Children, s); delete(h);
end

end


