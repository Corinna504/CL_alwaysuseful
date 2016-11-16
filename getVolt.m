
function volt = getVolt(ex)

volt = nan;
if isfield(ex.Header, 'Headers')
    if isfield(ex.Header.Headers(1), 'iontophoresisVoltage')
        volt = ex.Header.Headers(1).iontophoresisVoltage;
    end
else
    if isfield(ex.Header, 'iontophoresisVoltage')
        volt = ex.Header.iontophoresisVoltage;
    end
end
end