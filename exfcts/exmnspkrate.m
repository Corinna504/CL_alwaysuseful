function mu_rate = exmnspkrate( ex )

param = ex.exp.e1.type;
parvls = unique([Trials.(param1)]);
kk=0;

for par = parvls
    
    ind = par == [Trials.(param)];
    
    if any(ind)
        kk = kk+1;
        % get tuning means
        mu_rate(kk).(param) = par;
        mu_rate(kk).mu = mean([Trials(ind).spkRate]);
        mu_rate(kk).spks = [Trials(ind).spkRate];
        mu_rate(kk).var = var([Trials(ind).spkRate]);
        mu_rate(kk).sme = std([Trials(ind).spkRate]) / sqrt( sum(ind) );
        
         
        %         mu_rate(kk).mu0 = mean([Trials(ind).spkRateC0]);
        %         mu_rate(kk).var0 = var([Trials(ind).spkRateC0]);
        %         mu_rate(kk).val  = par;
         
        %         mu_count(kk).(partypes{1}) = par1;
        %         mu_count(kk).mu1 = mean([Trials(ind).spkCountC1]);
        %         mu_count(kk).mu0 = mean([Trials(ind).spkCountC0]);
        %         mu_count(kk).var1 = var([Trials(ind).spkCountC1]);
        %         mu_count(kk).var0 = var([Trials(ind).spkCountC0]);
        %         mu_count(kk).val  = par1;
    end
end

end


