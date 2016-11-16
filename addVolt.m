function exinfo = addVolt(exinfo)


for i = 1:length(exinfo)
    load(exinfo(i).fname_drug)
    exinfo(i).volt = getVolt(ex);
    
end

end


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