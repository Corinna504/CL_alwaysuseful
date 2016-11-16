function dose = getDose(ex)
        dose = -1;

if isfield(ex.Header, 'Headers')
    if isfield(ex.Header.Headers(1), 'iontophoresisEjectionCurrent')
        dose = ex.Header.Headers(1).iontophoresisEjectionCurrent;
    end
else
    if isfield(ex.Header, 'iontophoresisEjectionCurrent')
        dose = ex.Header.iontophoresisEjectionCurrent;
    end
end
end
