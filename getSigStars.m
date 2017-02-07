
function stars = getSigStars(p)

if p >=0 %parametric test
    if p < 0.001
        stars = '***_{p}';
    elseif p<0.01
        stars = '**_{p}';
    elseif p<0.05
        stars = '*_{p}';
    elseif p<0.08
        stars = 'o_{p}';
    else
        stars = ' _{p}';
    end
    
elseif p<0 %non-parametric test
    
    if p > -0.001
        stars = '***_{np}';
    elseif p>-0.01
        stars = '**_{np}';
    elseif p>-0.05
        stars = '*_{np}';
    elseif p>-0.08
        stars = 'o_{np}';
    else
        stars = ' _{np}';
    end
    
end
end
