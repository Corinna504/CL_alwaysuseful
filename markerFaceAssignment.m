function col = markerFaceAssignment( exinfo )

if exinfo.ismango
    if exinfo.is5HT
        col = 'r';
    else
        col = 'k';
    end
else
    col = 'w';
end


end

