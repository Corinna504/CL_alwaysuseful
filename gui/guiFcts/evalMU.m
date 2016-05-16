function dat = evalMU(fctX, fctY, expInfo)

if strfind(fctX, 'time')
    dat = assignFctXY(fctX, fctY, expInfo);
elseif  strfind(fctY, 'time')
    dat = assignFctXY(fctY, fctX, expInfo);
else
    [dat.x, ~, dat.xlab, ~] = assignFct(fctX, expInfo);
    [dat.y, dat.err, dat.ylab, dat.info] = assignFct(fctY, expInfo);
end

if size(dat.x) == size(dat.y)
    dat.info = sprintf([dat.info ' results %3f %3f'], corr(dat.x, dat.y));
end

end


function [val, err, lab, info] = assignFct(fctname, expInfo)

lat_std_t = 201:400;

lab = fctname;
info = [];
err = [];

switch fctname
    
    case 'blank diff'
        val = assignFct('blank base', expInfo) - ...
                assignFct('blank drug', expInfo);
        
            lab = [lab ' (base-drug)']
            
    case 'blank base'
        for i = 1:length(expInfo)
            if any(expInfo(i).ratepar > 1000) && any(expInfo(i).ratepar_drug > 1000)
                val(i) = expInfo(i).ratemn(expInfo(i).ratepar > 1000);
            else
                val(i) = nan;
            end
        end
        
    case 'blank drug'    
        for i = 1:length(expInfo)
            if any(expInfo(i).ratepar > 1000) && any(expInfo(i).ratepar_drug > 1000)
                val(i) = expInfo(i).ratemn_drug(expInfo(i).ratepar_drug > 1000);
            else
                val(i) = nan;
            end
        end
        
    case 'BRI ACF base'
        for i = 1:length(expInfo)
            if ~isempty(expInfo(i).bridx)
                val(i) = expInfo(i).bridx(1);
            else
                val(i) = nan;
            end
        end
    case  'BRI ACF drug'
        for i = 1:length(expInfo)
            if ~isempty(expInfo(i).bridx)
                val(i) = expInfo(i).bridx(2);
            else
                val(i) = nan;
            end
        end
    case 'BRI ISI base'
        for i = 1:length(expInfo)
            if ~isnan(expInfo(i).isi_frct)
                val(i) = expInfo(i).isi_frct(1);
            else 
                val(i) = nan;
            end
        end
    case 'BRI ISI drug'
        for i = 1:length(expInfo)
             if ~isnan(expInfo(i).isi_frct)
                 val(i) = expInfo(i).isi_frct(2);
             else
                 val(i) = nan;
             end
        end
        
    case 'SMI'
        val = (cellfun(@max, {expInfo.ratemn}) - cellfun(@max, {expInfo.ratemn_drug}))  ./ ...
               (cellfun(@max, {expInfo.ratemn}) + cellfun(@max, {expInfo.ratemn_drug}));
        
        
    case 'Osz alpha (8-10) base'
        for i  =1:length(expInfo)
            if expInfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(expInfo(i).powstim_mn(expInfo(i).pfi, 9:11));
            end
        end
        
    case 'Osz alpha (8-10) drug'
        for i  =1:length(expInfo)
            if expInfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(expInfo(i).powstim_mn_drug(expInfo(i).pfi_drug, 9:11));
            end
        end
        
    case 'Osz beta (10-30) base'
        for i  =1:length(expInfo)
            if expInfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(expInfo(i).powstim_mn(expInfo(i).pfi, 11:31));
            end
        end
        
    case 'Osz beta (10-30) drug'
        for i  =1:length(expInfo)
            if expInfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(expInfo(i).powstim_mn_drug(expInfo(i).pfi_drug, 11:31));
            end
        end
        
    case 'Osz gamma (30-80) base'
        for i  =1:length(expInfo)
            if expInfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(expInfo(i).powstim_mn(expInfo(i).pfi, 31:81));
            end
        end
        
    case 'Osz gamma (30-80) drug'
        for i  =1:length(expInfo)
            if expInfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(expInfo(i).powstim_mn_drug(expInfo(i).pfi_drug, 31:81));
            end
        end
        
        
    case 'Osz alpha diff'
        val = assignFct('Osz alpha (8-10) base', expInfo) - ...
            assignFct('Osz alpha (8-10) drug', expInfo);
        lab = [fctname ' (base-drug)'];

    case 'Osz beta diff'
        val = assignFct('Osz beta (10-30) base', expInfo) - ...
            assignFct('Osz beta (10-30) drug', expInfo);
        lab = [fctname ' (base-drug)'];
        
    case 'Osz gamma diff'
        val = assignFct('Osz gamma (30-80) base', expInfo) - ...
            assignFct('Osz gamma (30-80) drug', expInfo);
        lab = [fctname ' (base-drug)'];
        
        
    case 'electrode depth'
        
        val = [expInfo.ed];

    case 'change in mean resp'
        
        for i=1:length(expInfo)
            val(i) = mean(expInfo(i).ratemn) - mean(expInfo(i).ratemn_drug);
        end
        
        lab = [fctname ' (base-drug)'];
        
    case 'smallest response'
        
        for i=1:length(expInfo)
            val(i) = min(expInfo(i).ratemn);
        end
        
        lab = fctname;

        
    case 'smallest response drug'
        
        for i=1:length(expInfo)
            val(i) = min(expInfo(i).ratemn_drug);
        end
        
        lab = fctname;   
    
    case 'smallest response overall'
        
        
        val = min([assignFct('smallest response', expInfo); ...
            assignFct('smallest response drug', expInfo)]);
        
        lab = fctname;   
        
    case 'response duration'
        for i = 1:length(expInfo)
            sd = sqrt(expInfo(i).resvars) - mean(sqrt(expInfo(i).resvars));
            noise = sd(201:400);
            if max((sd))>mean((sd(201:400)))*5
                sd = sd-mean(noise);     % normalize
                idx = find( sd >= (max(sd)/2), 1, 'last');
                val(i) =  expInfo(i).times(idx)/10 - expInfo(i).lat;
            else
                val(i) = 0;
            end
        end
        lab = fctname;
        
    case 'response duration drug'
        for i = 1:length(expInfo)
            sd = sqrt(expInfo(i).resvars_drug) - mean(sqrt(expInfo(i).resvars_drug));
            noise = sd(201:400);
            if max((sd))>mean((sd(201:400)))*5
                sd = sd-mean(noise);     % normalize
                idx = find( sd >= (max(sd)/2), 1, 'last');
                val(i) = expInfo(i).times_drug(idx)/10 - expInfo(i).lat_drug;
            else
                val(i) = 0;
            end
        end
        lab = fctname;
    
    case 'response duration diff'
        
        val = assignFct('response duration drug', expInfo) ...
            -assignFct('response duration', expInfo);
        lab = [fctname ' (base - drug)'];
        
    
    case 'latnoise'
        for i = 1:length(expInfo)
            val(i) = mean(sqrt(expInfo(i).resvars(lat_std_t)));
        end
        lab = fctname;
        
    case 'latnoise drug'
        for i = 1:length(expInfo)
            val(i) = mean(sqrt(expInfo(i).resvars_drug(lat_std_t)));
        end
        lab = fctname;
        
    case 'latnoise diff'
        
        val = assignFct('latnoise', expInfo) - ...
            assignFct('latnoise drug', expInfo);
        
        lab = [fctname '(base-drug)'];
        
    case 'pupil size base w1'
        val = assignPPSZ(expInfo, false, 'w1');
        lab = fctname;
        
    case 'pupil size base w2'
        val = assignPPSZ(expInfo, false, 'w2');
        lab = fctname;
        
    case 'pupil size base w3'
        val = assignPPSZ(expInfo, false, 'w3');
        lab = fctname;
        
    case 'pupil size base w4'
        val = assignPPSZ(expInfo, false, 'w4');
        lab = fctname;
        
        
    case 'pupil size drug w1'
        val = assignPPSZ(expInfo, 1, 'w1');
        lab = fctname;
        
    case 'pupil size drug w2'
        val = assignPPSZ(expInfo, 1, 'w2');
        lab = fctname;
        
    case 'pupil size drug w3'
        val = assignPPSZ(expInfo, 1, 'w3');
        lab = fctname;
        
    case 'pupil size drug w4'
        val = assignPPSZ(expInfo, 1, 'w4');
        lab = fctname;
        
    case 'latency base'
        val = [expInfo.lat];
        lab = fctname;
        
    case 'latency drug'
        val = [expInfo.lat_drug];
        lab = fctname;
        
    case 'latency diff'
        val = [expInfo.lat_drug] -[expInfo.lat];
        lab = 'latency diff (drug-base)';
        
    case 'latency base corrected'
%         val = [expInfo.lat] - [expInfo.reg_slope].*assignFct('latnoise', expInfo);
        val = [expInfo.lat];
        lab = fctname;
        
    case 'latency drug corrected'
%         val = [expInfo.lat_drug] - [expInfo.reg_slope].*assignFct('latnoise drug', expInfo);
        val = [expInfo.lat_drug] - ...
            ([expInfo.reg_slope].*assignFct('latnoise drug', expInfo) -...
            [expInfo.reg_slope].*assignFct('latnoise', expInfo) );
        lab = fctname;
        
    case 'latency diff corrected'
        val = assignFct('latency drug corrected', expInfo) - ...
            assignFct('latency base corrected', expInfo);
        lab = 'latency diff corrected (drug-base)';
        
    case 'correction factor'
        val = [expInfo.reg_slope];
        lab = fctname;
        
    case 'predicted latency'
%         val = [expInfo.reg_off] + [expInfo.reg_slope] .* assignFct('latnoise', expInfo);
        val = [expInfo.lat];
        lab = fctname;
        
    case 'predicted latency drug'
%         val = [expInfo.reg_off] + [expInfo.reg_slope] .* assignFct('latnoise drug', expInfo);
        val = [expInfo.lat] + ([expInfo.reg_slope].*assignFct('latnoise drug', expInfo) -...
            [expInfo.reg_slope].*assignFct('latnoise', expInfo) );
        lab = fctname;
        
    case 'predicted latency diff'
        val = assignFct('predicted latency drug', expInfo) -...
            assignFct('predicted latency', expInfo);
        lab = [fctname ' (drug - base)'];
        
    case 'predicted - true latency'
        val = assignFct('predicted latency', expInfo) - [expInfo.lat];
        lab = fctname;
 
    case 'predicted - true latency drug'
        val = assignFct('predicted latency drug', expInfo) - [expInfo.lat_drug];
        lab = fctname;
        
    case 'noise correlation'
        val = [expInfo.rsc];
        lab = 'noise correlation';
        
    case 'noise correlation drug'
        val = [expInfo.rsc_drug];
        lab = 'noise correlation drug';
        
    case 'noise correlation diff'
        val = [expInfo.rsc] - [expInfo.rsc_drug];
        lab = 'noise correlation diff (base-drug)';
        
    case  'signal correlation'
        val = [expInfo.rsig];
        lab = 'signal correlation';
        
    case 'signal correlation drug'
        val = [expInfo.rsig_drug];
        lab = 'signal correlation drug';
        
    case 'signal correlation diff'
        val = [expInfo.rsig] - [expInfo.rsig_drug];
        lab = 'signal correlation diff (base-drug)';
        
    case 'mean spike rate base'
        val = cellfun(@mean, {expInfo.ratemn},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate';
        
    case 'mean spike rate drug'
        val = cellfun(@mean, {expInfo.ratemn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate drug';
        
    case 'mean spike rate diff'
        val =  cellfun(@mean, {expInfo.ratemn},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {expInfo.ratemn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike rate diff';
        
    case 'mean spike rate variance base'
        val = cellfun(@mean, {expInfo.ratevars},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate variance';
        
    case 'mean spike rate variance drug'
        val = cellfun(@mean, {expInfo.ratevars_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate variance drug';
        
    case 'mean spike rate variance diff'
        val =  cellfun(@mean, {expInfo.ratevars},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {expInfo.ratevars_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike rate diff';
        
    case 'mean spike count base'
        val = cellfun(@mean, {expInfo.spkCount_mn},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count';
        
    case 'mean spike count drug'
        val = cellfun(@mean, {expInfo.spkCount_mn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count drug';
        
    case 'mean spike count diff'
        
        val =  cellfun(@mean, {expInfo.spkCount_mn},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {expInfo.spkCount_mn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike count diff';
        
    case 'mean spike count variance base'
        val = cellfun(@mean, {expInfo.spkCount_var},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count variance';
        
    case 'mean spike count variance drug'
        val = cellfun(@mean, {expInfo.spkCount_var_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count variance drug';
        
    case 'mean spike count variance diff'
        val =  cellfun(@mean, {expInfo.spkCount_var},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {expInfo.spkCount_var_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike count variance diff';
        
    case 'r2'
        val = [expInfo.rsqr4both];
        lab = 'r2 for both';
        
    case 'gain change'
        val = [expInfo.gslope];
        lab = 'gain change';
        
    case 'additive change'
        val = [expInfo.yoff];
        lab = 'additive change';
        
    case 'fano factor base'
        for i = 1:length(expInfo)
            val(i) = [expInfo(i).ff.classic];
        end
        lab = 'fano factor';
        
    case 'fano factor drug'
        for i = 1:length(expInfo)
            val(i) = [expInfo(i).ff_drug.classic];
        end
        lab = 'fano factor drug';
        
    case 'fano factor diff'
        for i = 1:length(expInfo)
            val(i) = [expInfo(i).ff.classic] - [expInfo(i).ff_drug.classic];
        end
        lab = 'fano factor diff';
        
    case 'fano factor fit base'
        for i = 1:length(expInfo)
            val(i) = [expInfo(i).ff.fit]
        end;
        lab = 'fano factor fit';
        
    case 'fano factor fit drug'
        for i = 1:length(expInfo)
            val(i) = [expInfo(i).ff_drug.fit]
        end;
        lab = 'fano factor fit drug';
        
    case 'fano factor fit diff'
        for i = 1:length(expInfo)
            val(i) = [expInfo(i).ff.fit] - [expInfo(i).ff_drug.fit];
        end
        lab = 'fano factor fit diff';
        
    case 'wave width'
        val = [expInfo.wdt];
        lab = 'wave width';
        
    case 'pupil size'
        
    case 'spike field coherence'
        
    case 'tc ampl base'
        val = [expInfo.tcdiff];
        lab = 'tuning curve difference base';
        
    case 'tc ampl drug'
        val = [expInfo.tcdiff_drug];
        lab = 'tuning curve difference drug';
        
    case 'tc ampl diff'
        val = [expInfo.tcdiff] - [expInfo.tcdiff_drug];
        lab = 'tuning curve difference diff';
    case 'fano factor mitchel bins'
        binrg = log([0.1 0.1778 0.31 0.5623 1 1.7783 3.10 5.6234 10 20]);
        val = exp( binrg(1)+mean(diff(binrg))/2 : mean(diff(binrg)) : binrg(9)+0.2+mean(diff(binrg))/2);
        lab = 'mean spike count (per 100ms)';
        
    case 'fano factor mitchel variance'
        
        kk = 1;
        for i = 1:length(expInfo)
            if expInfo(i).is5HT
                val_{kk,1}  = [expInfo(i).ff.mitchel.mn];
                val_{kk,2}  = [expInfo(i).ff_drug.mitchel.mn];
                
                err_{kk,1} = [expInfo(i).ff.mitchel.sem];
                err_{kk,2} = [expInfo(i).ff_drug.mitchel.sem];
                kk = kk+1;
            end
        end
        
        
        val = [ nanmean(horzcat(val_{:,1}), 2), nanmean(horzcat(val_{:,2}), 2)];
        err = [ nanmean(horzcat(err_{:,1}), 2), nanmean(horzcat(err_{:,2}), 2)];
        
        kk = 1;
        for i = 1:length(expInfo)
            if expInfo(i).is5HT
                cmp(kk, :) =  [expInfo(i).ff.mitchel.mn];
                cmp_drug(kk,:) = [expInfo(i).ff_drug.mitchel.mn];
                kk=kk+1;
            end
        end
        
        for i=1:9
            p(i) = ranksum(cmp(:,i), cmp_drug(:,i));
        end
        
        lab = 'spike count variance';
        info = [' p-values:' num2str(p) ' '] ;
        
    case 'cl gauss fit mu base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = expInfo(i).fitparam.mu;
            end
        end
        lab = fctname;
        
    case 'cl gauss fit mu drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = expInfo(i).fitparam_drug.mu;
            end
        end
        lab = fctname;
        
    case 'cl gauss fit mu diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = expInfo(i).fitparam.mu - expInfo(i).fitparam_drug.mu;
            end
        end
        val(val>90) = 180-val(val>90);
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit sig base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.sig];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit sig drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam_drug.sig];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit sig diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.sig] - [expInfo(i).fitparam_drug.sig];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit a base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.a];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit a drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam_drug.a];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit a diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam.a] - [expInfo(i).fitparam_drug.a];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit off base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.b];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit off drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam_drug.b];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit off diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam.b] - [expInfo(i).fitparam_drug.b];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit r2 base'
        val = [expInfo.gaussr2];
        lab = fctname;
        
    case 'cl gauss fit r2 drug'
        val = [expInfo.gaussr2_drug];
        lab = fctname;
        
        
    case 'cl gauss fit r2 diff'
        val = [expInfo.gaussr2]-[expInfo.gaussr2_drug];
        lab = [fctname '(base-drug)'];
        
        
        
        
    case 'hn gauss fit mu base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = expInfo(i).fitparam.HN.mean;
            end
        end
        lab = fctname;
        
    case 'hn gauss fit mu drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = expInfo(i).fitparam_drug.HN.mean;
            end
        end
        lab = fctname;
        
    case 'hn gauss fit mu diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = expInfo(i).fitparam.HN.mean - expInfo(i).fitparam_drug.HN.mean;
            end
        end
        val(val>90) = 180-val(val>90);
        lab = [fctname '(base-drug)'];
        
    case 'hn gauss fit sig base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.HN.sd];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit sig drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam_drug.HN.sd];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit sig diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.HN.sd] - [expInfo(i).fitparam_drug.HN.sd];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'hn gauss fit a base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.HN.amp];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit a drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam_drug.HN.amp];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit a diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam.HN.amp] - [expInfo(i).fitparam_drug.HN.amp];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'hn gauss fit off base'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam )
                val(i)  = [expInfo(i).fitparam.HN.base];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit off drug'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam_drug.HN.base];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit off diff'
        for i =1:length(expInfo)
            if ~isempty ( expInfo(i).fitparam_drug )
                val(i)  = [expInfo(i).fitparam.HN.base] - [expInfo(i).fitparam_drug.HN.base];
            end
        end
        lab = [fctname '(base-drug)'];
        %
        %     case 'hn gauss fit r2 base'
        %         val = [expInfo.gaussr2];
        %         lab = fctname;
        %
        %     case 'hn gauss fit r2 drug'
        %         val = [expInfo.gaussr2_drug];
        %         lab = fctname;
        %
        %
        %     case 'hn gauss fit r2 diff'
        %         val = [expInfo.gaussr2]-[expInfo.gaussr2_drug];
        %         lab = [fctname '(base-drug)'];
end
end



function dat = assignFctXY(fcttime, fctother, datinfo)


[dat.y, dat.ylab] = assignFct(fctother, datinfo);

dat.xlab = fcttime;

switch fcttime
    
    case 'experiment time'
        
        for neuron = unique([datinfo.id])
            neuron_idx = find([datinfo.id] == neuron);
            
            [b, idx] = sort(unique([datinfo(neuron_idx).date]));
            
            for i = 1:length(b)
                dat.x(neuron_idx([datinfo(neuron_idx).date] == b(i))) = idx(i);
            end
        end
        
    case 'trial time'
        dat.x = 1:length(datinfo);
end

end



function val = assignPPSZ(expInfo, drug_flag, w_name)

if drug_flag
    fname = 'ppsz_mu_drug';
else
    fname = 'ppsz_mu';
end

for i = 1:length(expInfo)
    
    if isfield(expInfo(i).(fname), w_name)
        val(i) = expInfo(i).(fname).(w_name);
    end
    
end

end


