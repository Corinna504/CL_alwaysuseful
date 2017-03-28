function exinfo = getExInfo( varargin )


disp('STARTED DATA PREPROCESSING');

exinfo = [];
p_flag = false;
i_strt = 1; 
fig_suffix = '';
saveflag = false;
j = 1;
rng(2384569);

    
while  j<= length(varargin)
    switch varargin{j}
        case 'plot'
            p_flag = true;
            j = j+1;
            close all
        case 'i_strt'
            i_strt = varargin{j+1};
            %             load 'expInfo_All_temp.mat' 'exinfo';
            j = j+2;
        case 'info'
            exinfo = varargin{j+1};
            j = j+2;
        case 'save'
            saveflag = true;
            j = j+1;
        case 'figsuf'
            fig_suffix = varargin{j+1};
            j = j+2;
        otherwise
                j = j+1;
    end
end


%% load general information (fignames, ex foldernames, etc.)
if isempty(exinfo)
    exinfo = loadGeneralInfo(varargin{:});
end

%% go through each file and add other information
for kk = i_strt:length(exinfo)

%     if exinfo(kk).isRC 
%         continue;
%     end
    
    fprintf('WORKING ON ROW %1i, file %1.1f \n', kk, exinfo(kk).id);
    exinfo(kk) = replaceFigName(exinfo(kk), fig_suffix);

    %--------------------------------------- operations on single ex files
    %base
    [ex0, args0] = evalSingleEx(exinfo(kk), exinfo(kk).fname, varargin{:});
    exinfo(kk) = assignInfo(exinfo(kk), '', args0{:});
    
    %drug
    [ex2, args2] = evalSingleEx(exinfo(kk), exinfo(kk).fname_drug, varargin{:});
    exinfo(kk) = assignInfo(exinfo(kk), '_drug', args2{:});

    %-------------------------------------- operations on both ex files
    exinfo(kk).tf = ex0.stim.vals.tf;
    exinfo(kk) = evalBothEx(ex0, ex2,  exinfo(kk), p_flag, varargin{:});
  
    %-------------------------------------- additional fitting for 2D
    if exinfo(kk).isRC && ~isempty(strfind(exinfo(kk).fname, 'CO'))
        [exinfo(kk).gain_2D, exinfo(kk).off_2D] = ...
            get2Dreg(exinfo(kk));
        ex0.Trials =[]; ex2.Trials=[];
    else        
        exinfo(kk).gain_2D = nan;
        exinfo(kk).off_2D = nan;
    end
    
    %-------------------------------------- plot results

    if ~exinfo(kk).isRC

        if p_flag && ~exinfo(kk).isadapt

           exinfo(kk) = new_psthPlot_red(exinfo(kk), ex0, ex2);
           rasterPlot( exinfo(kk), ex0, ex2);
           tuningCurvePlot(exinfo(kk));        
           znormplot(ex0, ex2, exinfo(kk));
           exinfo(kk) = phasePlot(exinfo(kk), ex0, ex2);
           
           VariabilityPlot(exinfo(kk), ex0, ex2);
        end

        exinfo(kk) = getISI_All(exinfo(kk), ex0, ex2, p_flag);

    elseif exinfo(kk).isRC && p_flag
        rcPlot(exinfo(kk));
        tuningCurvePlot(exinfo(kk));  
    end
    
    %-------------------------------------- temp save
    if saveflag && mod(kk, 30)==0 
        save(['exinfo' fig_suffix '.mat'], 'exinfo', '-v7.3'); 
    end
end

%------------------------------------------------------------- add fields
exinfo = getValidField(exinfo);
exinfo = getDominantEyeField(exinfo);
exinfo = setReceptiveFieldSize( exinfo );
exinfo = addSortingValue(exinfo);
exinfo = addNumInExp(exinfo);
exinfo = addStruct(exinfo);


if saveflag; save(['exinfo' fig_suffix '.mat'], 'exinfo', '-v7.3'); end

end

function info = assignInfo(info, apx, varargin)
% arguments assigned to in evalSingleEx
j = 1;


while j<length(varargin)

    switch varargin{j}
        
        case 'lat'
            eval([ 'info.lat' apx ' = varargin{j+1};']);
        case 'lat2Hmax'
            eval([ 'info.lat2Hmax' apx ' = varargin{j+1};']);
        case 'fitparam'
            eval([ 'info.fitparam' apx ' = varargin{j+1};']);
        case 'rateMN'
            eval([ 'info.ratemn' apx ' = varargin{j+1};']);
        case 'rateVARS'
            eval([ 'info.ratevars' apx ' = varargin{j+1};']);
        case 'ratePAR'
            eval([ 'info.ratepar' apx ' = varargin{j+1};']);
        case 'rateSME'
            eval([ 'info.ratesme' apx ' = varargin{j+1};']);
        case 'rateSD'
            eval([ 'info.ratesd' apx ' = varargin{j+1};']);
        case 'rawspkrates'
            eval([ 'info.rawspkrates' apx ' = varargin{j+1};']);
        case 'rate_resmpl'
            eval([ 'info.rate_resmpl' apx ' = varargin{j+1};']);
        case 'ff'
            eval([ 'info.ff' apx ' = varargin{j+1};']);
        case 'tcdiff'
            eval([ 'info.tcdiff' apx ' = varargin{j+1};']);
        case 'rsc'
            eval([ 'info.rsc' apx ' = varargin{j+1};']);
        case 'prsc'
            eval([ 'info.prsc' apx ' = varargin{j+1};']);
        case 'rsig'
            eval([ 'info.rsig' apx ' = varargin{j+1};']);
        case 'prsig'
            eval([ 'info.prsig' apx ' = varargin{j+1};']);
        case 'rsc_2nd'
            eval([ 'info.rsc_2nd' apx ' = varargin{j+1};']);
        case 'prsc_2nd'
            eval([ 'info.prsc_2nd' apx ' = varargin{j+1};']);
        case 'rsig_2nd'
            eval([ 'info.rsig_2nd' apx ' = varargin{j+1};']);
        case 'prsig_2nd'
            eval([ 'info.prsig_2nd' apx ' = varargin{j+1};']);
        case 'resvars'
            eval([ 'info.resvars' apx ' = varargin{j+1};']);
        case 'expduration'
            eval([ 'info.expduration' apx ' = varargin{j+1};']);
        case 'sdfs'
            eval([ 'info.sdfs' apx ' = varargin{j+1};']);
        case 'times'
            eval([ 'info.times' apx ' = varargin{j+1};']);
        case 'resdur'
            eval([ 'info.dur' apx ' = varargin{j+1};']);
        case 'ed'
            info.ed = varargin{j+1};
        case 'eX'
            info.eX = varargin{j+1};
        case 'eY'
            info.eY = varargin{j+1};
        case  'phasesel'
            eval([ 'info.phasesel' apx ' = varargin{j+1};']);
        case  'psth'
            eval([ 'info.psth' apx ' = varargin{j+1};']);
        case 'p_anova'
             eval([ 'info.p_anova' apx ' = varargin{j+1};']);
        case 'nrep'
            eval([ 'info.nrep' apx ' = varargin{j+1};']);
        case 'c0rate'
            eval([ 'info.c0rate' apx ' = varargin{j+1};']);
        case 'c0geomn'
            eval([ 'info.c0geomn' apx ' = varargin{j+1};']);
        case 'c0geomn_2nd'
            eval([ 'info.c0geomn_2nd' apx ' = varargin{j+1};']);
        case 'trials_c0'
            eval([ 'info.trials_c0' apx ' = varargin{j+1};']);
        case 'trials_c1'
            eval([ 'info.trials_c1' apx ' = varargin{j+1};']);
    end
    j = j+2;
end


end


function checkdir(fdir)
fnames = fieldnames(fdir);
for i = 1:length(fnames)
    if ~exist(fdir.(fnames{i}), 'dir')
        mkdir(fdir.(fnames{i}));
    end
end
end
  

function loadLFPfig(exinfo)


 if exinfo.isc2
     lfpnameB = strrep(exinfo.fname, 'c2', 'lfp');
     lfpnameD = strrep(exinfo.fname_drug, 'c2', 'lfp');
 else
     lfpnameB = strrep(exinfo.fname, 'c1', 'lfp');
     lfpnameD = strrep(exinfo.fname_drug, 'c1', 'lfp');
 end
 
exfB = exist(lfpnameB, 'file')==2; % baseline
exfD = exist(lfpnameD, 'file')==2; % drug


%% try to load files
try
    % spikes
    exSpkin = loadCluster(exinfo.fname);
    exSpkin2 = loadCluster(exinfo.fname_drug);
    
    % lfp
    exLFPin = loadCluster(lfpnameB);
    exLFPin2 = loadCluster(lfpnameD);
    
    if all(cellfun(@isempty, {exLFPin2.Trials.LFP})) || all(cellfun(@isempty, {exLFPin2.Trials.LFP}))
        fprintf(['     all LFP entries are empty    ' exinfo.figname '\n']);
        return
    end
    
catch
    close all
    fprintf(['     issue loading files    ' exinfo.figname '\n']);
    return
end

return
%% try to analyse and plot files
try
    exSpkin.Trials = exSpkin.Trials( [exSpkin.Trials.me] == exinfo.ocul);
    exSpkin2.Trials = exSpkin2.Trials( [exSpkin2.Trials.me] == exinfo.ocul);
    
    exLFPin.Trials = exLFPin.Trials( [exLFPin.Trials.me] == exinfo.ocul);
    exLFPin2.Trials = exLFPin2.Trials( [exLFPin2.Trials.me] == exinfo.ocul);
    
    %     [hlfp,fig_spect] = LFPGui( exSpkin, exLFPin, exSpkin2, exLFPin2);
    
    
    LFPplotBatch( exSpkin, exLFPin, exSpkin2, exLFPin2 )
    lfpfig = findobj('tag', 'lfp');
    spkavg = findobj('tag', 'spk_avg');
    
    
    set(lfpfig, 'Name', exinfo.figname);
    savefig(lfpfig, exinfo.fig_lfpPow); delete(lfpfig);
    
    set(spkavg, 'Name', exinfo.figname);
    savefig(spkavg, exinfo.fig_lfpAvgSpk);
    
    close all
catch
    close all
    fprintf(['     issues with the LFP function    ' exinfo.figname '\n']);
end
end


function exinfo = replaceFigName(exinfo, fig_suffix)

exinfo.fig_regl = [exinfo.fig_regl(1:end-4), fig_suffix, '.fig'];
exinfo.fig_sdfs= [exinfo.fig_sdfs(1:end-4), fig_suffix, '.fig'];
exinfo.fig_tc = [exinfo.fig_tc(1:end-4), fig_suffix, '.fig'];
exinfo.fig_raster = [exinfo.fig_raster(1:end-4), fig_suffix, '.fig'];
exinfo.fig_varxtime = [exinfo.fig_varxtime(1:end-4), fig_suffix, '.fig'];
exinfo.fig_noisecorr = [exinfo.fig_noisecorr(1:end-4), fig_suffix, '.fig'];
end
