
function stars = getSigStars(p)

if p < 0.001
    stars = '***';
elseif p<0.01
    stars = '**';
elseif p<0.05
    stars = '*';
else
    stars = '';
end
end
