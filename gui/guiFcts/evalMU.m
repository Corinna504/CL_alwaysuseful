function dat = evalMU(fctX, fctY, exinfo)

if strfind(fctX, 'time')
    dat = assignFctXY(fctX, fctY, exinfo);
elseif  strfind(fctY, 'time')
    dat = assignFctXY(fctY, fctX, exinfo);
else
    [dat.x, ~, dat.xlab, ~] = assignFct(fctX, exinfo);
    [dat.y, dat.err, dat.ylab, dat.info] = assignFct(fctY, exinfo);
end

if size(dat.x) == size(dat.y)
    dat.info = sprintf([dat.info ' results %3f %3f'], corr(dat.x, dat.y));
end


dat.exinfo = exinfo(~isnan(dat.x));

if size(dat.y,1)>1
    dat.y  = dat.y(~isnan(dat.x),:);
else
    dat.y  = dat.y(~isnan(dat.x));
end
dat.x  = dat.x(~isnan(dat.x));

end


function [val, err, lab, info] = assignFct(fctname, exinfo)

lat_std_t = 201:400;

lab = fctname;
info = [];
err = [];

switch fctname
    
    
    case 'RF width x'
        for i = 1:length(exinfo)
            
            if isempty(exinfo(i).RFwx)
                val(i) = nan;
            else
                val(i) = exinfo(i).RFwx;
            end
        end
    case 'RF width y'
        for i = 1:length(exinfo)
            if isempty(exinfo(i).RFwy)
                val(i) = nan;
            else
                val(i) = exinfo(i).RFwy;
            end
        end
        
    case 'RF width mean'
        
        for i = 1:length(exinfo)
            if isempty(exinfo(i).RFw)
                val(i) = nan;
            else
                val(i) = exinfo(i).RFw;
            end
        end
        
        
    case 'pref size base'
        
        for i = 1:length(exinfo)
            if strcmp(exinfo(i).param1, 'sz')
                if  max(exinfo(i).fitparam.val.mn) == exinfo(i).fitparam.val.mn(end)
                    val(i) = exinfo(i).fitparam.val.mn(end);
                else
                    val(i) = exinfo(i).fitparam.mu;
                end
            else
                val(i) = nan;
            end
        end
        
        
    case 'pref size drug'
        
        for i = 1:length(exinfo)
            if strcmp(exinfo(i).param1, 'sz')
                if  max(exinfo(i).fitparam_drug.val.mn) == exinfo(i).fitparam_drug.val.mn(end)
                    val(i) = exinfo(i).fitparam_drug.val.mn(end);
                else
                    val(i) = exinfo(i).fitparam_drug.mu;
                end
            else
                val(i) = nan;
            end
        end
        
    case 'pref size diff'
        val = assignFct('pref size base' , exinfo) - ...
            assignFct('pref size drug' , exinfo);
        lab = [fctname ' (base-drug)'];
        
        
    case 'nonparam area ratio'
        
        val = [exinfo.nonparam_ratio];
        
    case 'MI'
        val = [exinfo.MI];
        
    case 'pf stim raw base'
        for i =1:length(exinfo)
            [~, idx] = max( exinfo(i).ratemn );
            val(i) = exinfo(i).ratepar(idx);
        end
    case 'pf stim raw drug'
        for i =1:length(exinfo)
            [~, idx] = max( exinfo(i).ratemn_drug );
            val(i) = exinfo(i).ratepar_drug(idx);
        end
    case 'pf stim raw diff'
        val = assignFct('pf stim raw base' , exinfo) - ...
            assignFct('pf stim raw drug' , exinfo);
        lab = [fctname ' (base-drug)'];
        
    case 'SI base'
        for i =1:length(exinfo)
            if isfield(exinfo(i).fitparam, 'SI')
                val(i) = exinfo(i).fitparam.SI;
            else
                val(i) = nan;
            end
        end
        
        
    case 'SI drug'
        for i =1:length(exinfo)
            if isfield(exinfo(i).fitparam_drug, 'SI')
                val(i) = exinfo(i).fitparam_drug.SI;
            else
                val(i) = nan;
            end
        end
        
        
    case 'SI diff'
        val = assignFct('SI base' , exinfo) - ...
            assignFct('SI drug' , exinfo);
        lab = [fctname ' (base-drug)'];
        
    case 'volt'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).volt;
        end
        
    case 'gain 2D'
        val = [exinfo.gain_2D];
        
        
    case 'off 2D'
        val = [exinfo.off_2D];
        
    case 'gain co'
        val = [exinfo.gain_co];
        
    case 'off co'
        val = [exinfo.off_co];
        
    case 'dose'
        val = [exinfo.dose];
        
    case  'r2 ag'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.sub.r2_ag;
        end
        val(val<0) = 0;
        
    case 'r2 cg'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.sub.r2_cg;
        end
        val(val<0) = 0;
        
    case 'r2 rg'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.sub.r2_rg;
        end
        val(val<0) = 0;
        
        
    case 'r2 rg cg diff'
        val = assignFct('r2 rg' , exinfo) - ...
            assignFct('r2 cg' , exinfo);
        
        
    case 'r2 ag cg diff'
        val = assignFct('r2 ag' , exinfo) - ...
            assignFct('r2 cg' , exinfo);
        
    case 'a ag'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.a_ag;
        end
        
    case 'a cg'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.a_cg;
        end
        
    case 'a rg'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.a_rg;
        end
        
    case 'phase selectivity'
        %         val = [exinfo.tf_f1f0];
        for i = 1:length(exinfo)
            if isnan(exinfo(i).tf_f1f0)
                val(i) = exinfo(i).phasesel;
            else
                val(i) = exinfo(i).tf_f1f0;
            end
        end
        
    case 'c50 base'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam.c50;
        end
        
        val(val>1.1) = 1.1;
    case 'c50 drug'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.c50;
        end
        val(val>1.1) = 1.1;
        
    case 'c50 diff'
        val = assignFct('c50 base', exinfo) - ...
            assignFct('c50 drug', exinfo);
        
        lab = [lab ' (base-drug)'];
        
    case 'rmax base'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam.rmax;
        end
        
    case 'rmax drug'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam_drug.rmax;
        end
        
    case 'rmax diff'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam.rmax - exinfo(i).fitparam_drug.rmax;
        end
        lab = [lab ' (base-drug)'];
        
        
    case 'co fit n'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam.n;
        end
        
    case 'co fit m'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).fitparam.m;
        end
    case 'blank diff'
        val = assignFct('blank base', exinfo) - ...
            assignFct('blank drug', exinfo);
        lab = [lab ' (base-drug)'];
        
    case 'blank base'
        for i = 1:length(exinfo)
            if any(exinfo(i).ratepar > 1000) && any(exinfo(i).ratepar_drug > 1000)
                val(i) = exinfo(i).ratemn(exinfo(i).ratepar > 1000);
            else
                val(i) = nan;
            end
        end
        
    case 'blank drug'
        for i = 1:length(exinfo)
            if any(exinfo(i).ratepar > 1000) && any(exinfo(i).ratepar_drug > 1000)
                val(i) = exinfo(i).ratemn_drug(exinfo(i).ratepar_drug > 1000);
            else
                val(i) = nan;
            end
            %                 val(i) = exinfo(i).ratemn_drug(exinfo(i).upfi);
            
        end
        
    case 'BRI ACF base'
        for i = 1:length(exinfo)
            if ~isempty(exinfo(i).bridx)
                val(i) = exinfo(i).bridx(1);
            else
                val(i) = nan;
            end
        end
    case  'BRI ACF drug'
        for i = 1:length(exinfo)
            if ~isempty(exinfo(i).bridx)
                val(i) = exinfo(i).bridx(2);
            else
                val(i) = nan;
            end
        end
    case 'BRI ISI base'
        for i = 1:length(exinfo)
            if ~isnan(exinfo(i).isi_frct)
                val(i) = exinfo(i).isi_frct(1);
            else
                val(i) = nan;
            end
        end
    case 'BRI ISI drug'
        for i = 1:length(exinfo)
            if ~isnan(exinfo(i).isi_frct)
                val(i) = exinfo(i).isi_frct(2);
            else
                val(i) = nan;
            end
        end
        
    case 'SMI'
        val = (cellfun(@max, {exinfo.ratemn}) - cellfun(@max, {exinfo.ratemn_drug}))  ./ ...
            (cellfun(@max, {exinfo.ratemn}) + cellfun(@max, {exinfo.ratemn_drug}));
        
        
    case 'Osz alpha (8-10) base'
        for i  =1:length(exinfo)
            if exinfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(exinfo(i).powstim_mn(exinfo(i).pfi, 9:11));
            end
        end
        
    case 'Osz alpha (8-10) drug'
        for i  =1:length(exinfo)
            if exinfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(exinfo(i).powstim_mn_drug(exinfo(i).pfi_drug, 9:11));
            end
        end
        
    case 'Osz beta (10-30) base'
        for i  =1:length(exinfo)
            if exinfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(exinfo(i).powstim_mn(exinfo(i).pfi, 11:31));
            end
        end
        
    case 'Osz beta (10-30) drug'
        for i  =1:length(exinfo)
            if exinfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(exinfo(i).powstim_mn_drug(exinfo(i).pfi_drug, 11:31));
            end
        end
        
    case 'Osz gamma (30-80) base'
        for i  =1:length(exinfo)
            if exinfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(exinfo(i).powstim_mn(exinfo(i).pfi, 31:81));
            end
        end
        
    case 'Osz gamma (30-80) drug'
        for i  =1:length(exinfo)
            if exinfo(i).powstim_mn_drug==0
                val(i) = nan;
            else
                val(i) = mean(exinfo(i).powstim_mn_drug(exinfo(i).pfi_drug, 31:81));
            end
        end
        
        
    case 'Osz alpha diff'
        val = assignFct('Osz alpha (8-10) base', exinfo) - ...
            assignFct('Osz alpha (8-10) drug', exinfo);
        lab = [fctname ' (base-drug)'];
        
    case 'Osz beta diff'
        val = assignFct('Osz beta (10-30) base', exinfo) - ...
            assignFct('Osz beta (10-30) drug', exinfo);
        lab = [fctname ' (base-drug)'];
        
    case 'Osz gamma diff'
        val = assignFct('Osz gamma (30-80) base', exinfo) - ...
            assignFct('Osz gamma (30-80) drug', exinfo);
        lab = [fctname ' (base-drug)'];
        
        
    case 'electrode depth'
        
        val = [exinfo.ed];
        
    case 'change in mean resp'
        
        for i=1:length(exinfo)
            val(i) = mean(exinfo(i).ratemn) - mean(exinfo(i).ratemn_drug);
        end
        
        lab = [fctname ' (base-drug)'];
        
    case 'smallest response'
        
        for i=1:length(exinfo)
            val(i) = min(exinfo(i).ratemn);
        end
        
        lab = fctname;
        
        
    case 'smallest response drug'
        
        for i=1:length(exinfo)
            val(i) = min(exinfo(i).ratemn_drug);
        end
        
        lab = fctname;
        
    case 'smallest response overall'
        
        
        val = min([assignFct('smallest response', exinfo); ...
            assignFct('smallest response drug', exinfo)]);
        
        lab = fctname;
        
    case 'response duration'
        for i = 1:length(exinfo)
            val(i) =  exinfo(i).dur;
        end
        lab = fctname;
        
    case 'response duration drug'
        for i = 1:length(exinfo)
            val(i) =  exinfo(i).dur_drug;
        end
        lab = fctname;
        
    case 'response duration diff'
        
        val = assignFct('response duration drug', exinfo) ...
            -assignFct('response duration', exinfo);
        lab = [fctname ' (base - drug)'];
        
        
    case 'latnoise'
        for i = 1:length(exinfo)
            val(i) = mean(sqrt(exinfo(i).resvars(lat_std_t)));
        end
        lab = fctname;
        
    case 'latnoise drug'
        for i = 1:length(exinfo)
            val(i) = mean(sqrt(exinfo(i).resvars_drug(lat_std_t)));
        end
        lab = fctname;
        
    case 'latnoise diff'
        
        val = assignFct('latnoise', exinfo) - ...
            assignFct('latnoise drug', exinfo);
        
        lab = [fctname '(base-drug)'];
        
    case 'pupil size base w1'
        val = assignPPSZ(exinfo, false, 'w1');
        lab = fctname;
        
    case 'pupil size base w2'
        val = assignPPSZ(exinfo, false, 'w2');
        lab = fctname;
        
    case 'pupil size base w3'
        val = assignPPSZ(exinfo, false, 'w3');
        lab = fctname;
        
    case 'pupil size base w4'
        val = assignPPSZ(exinfo, false, 'w4');
        lab = fctname;
        
        
    case 'pupil size drug w1'
        val = assignPPSZ(exinfo, 1, 'w1');
        lab = fctname;
        
    case 'pupil size drug w2'
        val = assignPPSZ(exinfo, 1, 'w2');
        lab = fctname;
        
    case 'pupil size drug w3'
        val = assignPPSZ(exinfo, 1, 'w3');
        lab = fctname;
        
    case 'pupil size drug w4'
        val = assignPPSZ(exinfo, 1, 'w4');
        lab = fctname;
        
    case 'latency base'
        for i = 1:length(exinfo)
            if size(exinfo(i).lat,1)>1
                if isempty(exinfo(i).pfi)
                    val(i) = exinfo(i).lat(2,end);
                else
                    try
                        val(i) = exinfo(i).lat(2,exinfo(i).pfi);
                    catch
                        c
                    end
                end
            else
                val(i) = exinfo(i).lat;
            end
        end
        val(isnan(val)) = -10;
        lab = fctname;
        
    case 'latency drug'
        for i = 1:length(exinfo)
            if size(exinfo(i).lat,1)>1
                if isempty(exinfo(i).pfi)
                    val(i) = exinfo(i).lat_drug(2,end);
                else
                    val(i) = exinfo(i).lat_drug(2,exinfo(i).pfi_drug);
                end
            else
                val(i) = exinfo(i).lat_drug;
            end
        end
        val(isnan(val)) = -10;
        lab = fctname;
        
    case 'latency hmax base'
        val = [exinfo.lat2Hmax];
        lab = fctname;
        
    case 'latency hmax drug'
        val = [exinfo.lat2Hmax_drug];
        lab = fctname;
        
    case 'latency hmax diff'
        val =  assignFct('latency hmax drug', exinfo) - ...
            assignFct('latency hmax base', exinfo);
        lab = 'latency hmax diff (drug-base)';
        
    case 'latency diff'
        val = assignFct('latency drug', exinfo) - ...
            assignFct('latency base', exinfo);
        lab = 'latency fp diff (drug-base)';
        
    case 'latency base corrected'
        val = [exinfo.lat2Hmax] - [exinfo.reg_slope].*assignFct('latnoise', exinfo);
        %         val = [exinfo.lat];
        lab = fctname;
        
    case 'latency drug corrected'
        val = [exinfo.lat2Hmax_drug] - [exinfo.reg_slope].*assignFct('latnoise drug', exinfo);
        %         val = [exinfo.lat_drug] - ...
        %             ([exinfo.reg_slope].*assignFct('latnoise drug', exinfo) -...
        %             [exinfo.reg_slope].*assignFct('latnoise', exinfo) );
        lab = fctname;
        
    case 'latency diff corrected'
        val = assignFct('latency drug corrected', exinfo) - ...
            assignFct('latency base corrected', exinfo);
        lab = 'latency diff corrected (drug-base)';
        
    case 'correction factor'
        val = [exinfo.reg_slope];
        lab = fctname;
        
    case 'predicted latency'
        %         val = [exinfo.reg_off] + [exinfo.reg_slope] .* assignFct('latnoise', exinfo);
        val = [exinfo.lat];
        lab = fctname;
        
    case 'predicted latency drug'
        %         val = [exinfo.reg_off] + [exinfo.reg_slope] .* assignFct('latnoise drug', exinfo);
        val = [exinfo.lat] + ([exinfo.reg_slope].*assignFct('latnoise drug', exinfo) -...
            [exinfo.reg_slope].*assignFct('latnoise', exinfo) );
        lab = fctname;
        
    case 'predicted latency diff'
        val = assignFct('predicted latency drug', exinfo) -...
            assignFct('predicted latency', exinfo);
        lab = [fctname ' (drug - base)'];
        
    case 'predicted - true latency'
        val = assignFct('predicted latency', exinfo) - [exinfo.lat];
        lab = fctname;
        
    case 'predicted - true latency drug'
        val = assignFct('predicted latency drug', exinfo) - [exinfo.lat_drug];
        lab = fctname;
        
    case 'noise correlation'
        val = [exinfo.rsc];
        lab = 'noise correlation';
        
    case 'noise correlation drug'
        val = [exinfo.rsc_drug];
        lab = 'noise correlation drug';
        
    case 'noise correlation diff'
        val = [exinfo.rsc] - [exinfo.rsc_drug];
        lab = 'noise correlation diff (base-drug)';
        
    case  'signal correlation'
        val = [exinfo.rsig];
        lab = 'signal correlation';
        
    case 'signal correlation drug'
        val = [exinfo.rsig_drug];
        lab = 'signal correlation drug';
        
    case 'signal correlation diff'
        val = [exinfo.rsig] - [exinfo.rsig_drug];
        lab = 'signal correlation diff (base-drug)';
        
    case 'mean spike rate base'
        val = cellfun(@mean, {exinfo.ratemn},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate';
        
    case 'mean spike rate drug'
        val = cellfun(@mean, {exinfo.ratemn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate drug';
        
        
    case 'norm mean spike rate base'
        
        val = cellfun(@mean, {exinfo.ratemn},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate';
        
    case 'norm mean spike rate drug'
        val = cellfun(@mean, {exinfo.ratemn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate drug';
        
        
        
    case 'mean spike rate diff'
        val =  cellfun(@mean, {exinfo.ratemn},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {exinfo.ratemn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val2 - val;
        lab = 'mean spike rate diff (drug-base)';
        
    case 'mean spike rate variance base'
        val = cellfun(@mean, {exinfo.ratevars},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate variance';
        
    case 'mean spike rate variance drug'
        val = cellfun(@mean, {exinfo.ratevars_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike rate variance drug';
        
    case 'mean spike rate variance diff'
        val =  cellfun(@mean, {exinfo.ratevars},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {exinfo.ratevars_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike rate diff';
        
    case 'mean spike count base'
        val = cellfun(@mean, {exinfo.spkCount_mn},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count';
        
    case 'mean spike count drug'
        val = cellfun(@mean, {exinfo.spkCount_mn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count drug';
        
    case 'mean spike count diff'
        
        val =  cellfun(@mean, {exinfo.spkCount_mn},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {exinfo.spkCount_mn_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike count diff';
        
    case 'mean spike count variance base'
        val = cellfun(@mean, {exinfo.spkCount_var},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count variance';
        
    case 'mean spike count variance drug'
        val = cellfun(@mean, {exinfo.spkCount_var_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        lab = 'mean spike count variance drug';
        
    case 'mean spike count variance diff'
        val =  cellfun(@mean, {exinfo.spkCount_var},...
            'UniformOutput', 0);
        val2 = cellfun(@mean, {exinfo.spkCount_var_drug},...
            'UniformOutput', 0);
        val = cell2mat(val);
        val2 = cell2mat(val2);
        val = val - val2;
        lab = 'mean spike count variance diff';
        
    case 'r2'
        val = [exinfo.r2reg];
        lab = 'regression r2';
        
    case 'gain change'
        val = [exinfo.gslope];
        lab = 'gain change';
        
    case 'additive change'
        val = [exinfo.yoff];
        lab = 'additive change';
        
    case 'additive change (rel)'
        val = [exinfo.yoff_rel];
        
    case 'gain change (rel)'
        val = [exinfo.gslope_rel];
        
    case 'fano factor base'
        for i = 1:length(exinfo)
            val(i) = nanmean([exinfo(i).ff.classic]);
        end
        lab = 'fano factor';
        
    case 'fano factor drug'
        for i = 1:length(exinfo)
            val(i) = nanmean([exinfo(i).ff_drug.classic]);
        end
        lab = 'fano factor drug';
        
    case 'fano factor diff'
        for i = 1:length(exinfo)
            val(i) = [exinfo(i).ff.classic] - [exinfo(i).ff_drug.classic];
        end
        lab = 'fano factor diff';
        
    case 'fano factor fit base'
        for i = 1:length(exinfo)
            val(i) = [exinfo(i).ff.fit]
        end;
        lab = 'fano factor fit';
        
    case 'fano factor fit drug'
        for i = 1:length(exinfo)
            val(i) = [exinfo(i).ff_drug.fit]
        end;
        lab = 'fano factor fit drug';
        
    case 'fano factor fit diff'
        for i = 1:length(exinfo)
            val(i) = [exinfo(i).ff.fit] - [exinfo(i).ff_drug.fit];
        end
        lab = 'fano factor fit diff';
        
    case 'wave width'
        for i = 1:length(exinfo)
            val(i) = exinfo(i).wdt(1);
        end
        lab = 'wave width';
        
    case 'pupil size'
        
    case 'spike field coherence'
        
    case 'tc ampl base'
        val = [exinfo.tcdiff];
        lab = 'tuning curve difference base';
        
    case 'tc ampl drug'
        val = [exinfo.tcdiff_drug];
        lab = 'tuning curve difference drug';
        
    case 'tc ampl diff'
        val = [exinfo.tcdiff] - [exinfo.tcdiff_drug];
        lab = 'tuning curve difference diff';
    case 'fano factor mitchel bins'
        binrg = log([0.1 0.1778 0.31 0.5623 1 1.7783 3.10 5.6234 10 20]);
        val = exp( binrg(1)+mean(diff(binrg))/2 : mean(diff(binrg)) : binrg(9)+0.2+mean(diff(binrg))/2);
        lab = 'mean spike count (per 100ms)';
        
    case 'fano factor mitchel variance'
        
        kk = 1;
        for i = 1:length(exinfo)
            if exinfo(i).is5HT
                val_{kk,1}  = [exinfo(i).ff.mitchel.mn];
                val_{kk,2}  = [exinfo(i).ff_drug.mitchel.mn];
                
                %                 err_{kk,1} = [exinfo(i).ff.mitchel.sem];
                %                 err_{kk,2} = [exinfo(i).ff_drug.mitchel.sem];
                
                kk = kk+1;
            end
        end
        
        
        val = [ nanmean(horzcat(val_{:,1}), 2), nanmean(horzcat(val_{:,2}), 2)];
        
        %         err = [ nanmean(horzcat(err_{:,1}), 2), nanmean(horzcat(err_{:,2}), 2)];
        err(:, 1) = nanstd( horzcat(val_{:, 1}), 0, 2 ) ./ ...
            sqrt(sum( isnan(horzcat(val_{:, 1})), 2 ));
        err(:, 2) = nanstd( horzcat(val_{:, 2}), 0, 2 ) ./ ...
            sqrt(sum( isnan(horzcat(val_{:, 2})), 2 ));
        
        
        kk = 1;
        for i = 1:length(exinfo)
            if exinfo(i).is5HT
                cmp(kk, :) =  [exinfo(i).ff.mitchel.mn];
                cmp_drug(kk,:) = [exinfo(i).ff_drug.mitchel.mn];
                kk=kk+1;
            end
        end
        
        for i=1:9
            p(i) = ranksum(cmp(:,i), cmp_drug(:,i));
        end
        
        lab = 'spike count variance';
        info = [' p-values:' num2str(p) ' '] ;
        
    case 'cl gauss fit mu base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = exinfo(i).fitparam.mu;
            end
        end
        lab = fctname;
        
    case 'cl gauss fit mu drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = exinfo(i).fitparam_drug.mu;
            end
        end
        lab = fctname;
        
    case 'cl gauss fit mu diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = exinfo(i).fitparam.mu - exinfo(i).fitparam_drug.mu;
            end
        end
        val(val>90) = 180-val(val>90);
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit sig base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.sig];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit sig drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam_drug.sig];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit sig diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.sig] - [exinfo(i).fitparam_drug.sig];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit a base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.a];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit a drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam_drug.a];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit a diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam.a] - [exinfo(i).fitparam_drug.a];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit off base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.b];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit off drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam_drug.b];
            end
        end
        lab = fctname;
        
    case 'cl gauss fit off diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam.b] - [exinfo(i).fitparam_drug.b];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'cl gauss fit r2 base'
        val = [exinfo.gaussr2];
        lab = fctname;
        
    case 'cl gauss fit r2 drug'
        val = [exinfo.gaussr2_drug];
        lab = fctname;
        
        
    case 'cl gauss fit r2 diff'
        val = [exinfo.gaussr2]-[exinfo.gaussr2_drug];
        lab = [fctname '(base-drug)'];
        
        
        
        
    case 'hn gauss fit mu base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = exinfo(i).fitparam.HN.mean;
            end
        end
        lab = fctname;
        
    case 'hn gauss fit mu drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = exinfo(i).fitparam_drug.HN.mean;
            end
        end
        lab = fctname;
        
    case 'hn gauss fit mu diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = exinfo(i).fitparam.HN.mean - exinfo(i).fitparam_drug.HN.mean;
            end
        end
        val(val>90) = 180-val(val>90);
        lab = [fctname '(base-drug)'];
        
    case 'hn gauss fit sig base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.HN.sd];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit sig drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam_drug.HN.sd];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit sig diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.HN.sd] - [exinfo(i).fitparam_drug.HN.sd];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'hn gauss fit a base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.HN.amp];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit a drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam_drug.HN.amp];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit a diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam.HN.amp] - [exinfo(i).fitparam_drug.HN.amp];
            end
        end
        lab = [fctname '(base-drug)'];
        
    case 'hn gauss fit off base'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam )
                val(i)  = [exinfo(i).fitparam.HN.base];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit off drug'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam_drug.HN.base];
            end
        end
        lab = fctname;
        
    case 'hn gauss fit off diff'
        for i =1:length(exinfo)
            if ~isempty ( exinfo(i).fitparam_drug )
                val(i)  = [exinfo(i).fitparam.HN.base] - [exinfo(i).fitparam_drug.HN.base];
            end
        end
        lab = [fctname '(base-drug)'];
        %
        %     case 'hn gauss fit r2 base'
        %         val = [exinfo.gaussr2];
        %         lab = fctname;
        %
        %     case 'hn gauss fit r2 drug'
        %         val = [exinfo.gaussr2_drug];
        %         lab = fctname;
        %
        %
        %     case 'hn gauss fit r2 diff'
        %         val = [exinfo.gaussr2]-[exinfo.gaussr2_drug];
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



function val = assignPPSZ(exinfo, drug_flag, w_name)

if drug_flag
    fname = 'ppsz_mu_drug';
else
    fname = 'ppsz_mu';
end

for i = 1:length(exinfo)
    
    if isfield(exinfo(i).(fname), w_name)
        val(i) = exinfo(i).(fname).(w_name);
    end
    
end

end


