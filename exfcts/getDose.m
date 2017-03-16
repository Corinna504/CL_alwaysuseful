function [dose, dosernd] = getDose(ex)
        dose = -1;

if isfield(ex.Header, 'Headers')
    if isfield(ex.Header.Headers(1), 'iontophoresisEjectionCurrent')
        dose(1) = ex.Header.Headers(1).iontophoresisEjectionCurrent;
    end
else
    if isfield(ex.Header, 'iontophoresisEjectionCurrent')
        dose(1) = ex.Header.iontophoresisEjectionCurrent;
    end
end
dosernd = getRoundDose(dose(1));
end


function dosernd = getRoundDose(dose)


if dose<0
    dosernd=-1;
elseif dose==0.1
    dosernd=-1;
elseif dose<=5
    dosernd=5;
elseif dose<=10
    dosernd=10;    
elseif dose<=16
    dosernd=16;    
elseif dose<=25
    dosernd=25;
elseif dose<=35
    dosernd = 35;
elseif dose<=inf
    dosernd = 45;
else
    dosernd = dose;
end


end