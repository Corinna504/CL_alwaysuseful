function exinfo = loadGeneralInfo(varargin)
% LOADGENERALINFO get all general information into the info struct
% go here to change the


%% initiate variables
kk = 0;
idi = 1;
fname = 'Z:\Corinna\filenames\SU110716_CL_all.txt';
exinfo = struct('id', [], 'idi', [], 'monkey', {}, 'dose', [], 'volt', [],...
        'gslope', [], 'yoff', [], ...
        'nonparam_ratio', 'r2reg', [], 'yoff_rel', [], 'r2reg_rel', [], ...
        'lat', [], 'lat_drug', [], ...
        'lat2Hmax', [], 'lat2Hmax_drug', [], ...
        'dur', [], 'dur_drug', [], ...
        'fitparam', [], 'fitparam_drug', [], ...
        'ratesme', [], 'ratesme_drug', [],...
        'ratesd', [], 'ratesd_drug', [],...
        'rawspkrates', [], 'rawspkrates_drug', [],...
        'ratepar', [], 'ratepar_drug', [], ...
        'ratemn' , [], 'ratemn_drug', [],...
        'ratevars', [], 'ratevars_drug', [], ...
        'nrep', [], 'nrep_drug', [], ...
        'tcdiff', [], 'tcdiff_drug', [], ...
        'ff', [], 'ff_drug', [], ...
        'ppsz_mu', [],'ppsz_mu_drug', [], ...
        'resvars', [], 'resvars_drug', [], ...
         'sdfs', {}, 'sdfs_drug', {}, ...
        'times', [], 'times_drug', [], ...
        'ismango', [], 'others', [], ...
        'ed', [], 'bridx', [], 'isi_frct', [],...
        'x0', [], 'y0', [], 'ecc', [],...
        'pfi', [], 'pfi_drug', [], 'upfi', [], 'upfi_drug', [], ...
        'tf_f1f0', [], ...
        'p_anova', [], 'p_anova_drug', [], ...
        'phasesel', [], 'phasesel_drug', [], ...
        'psth', {}, 'psth_drug', {}, 'electrodebroken', []);
    
%% check input
j = 1;
while j<=length(varargin)
    switch varargin{j}
        case 'fname'
            fname = varargin{j+1};
        case 'info'
            exinfo = varargin{j+1};
    end
    j = j+2;
end
            
    
%% save plots in specified folders 
pre = 'C:\Users\Corinna\Documents\Code\plots\';
fdir.TC = [pre 'TC'];
fdir.Regression = [pre 'Regression'];
fdir.Raster = [pre 'Raster'];
fdir.Waveform = [pre 'Waveform'];
fdir.PPSZdev = [pre 'PupilSizeDev'];
fdir.PPSZhist = [pre 'PupilSizeHist'];
fdir.RC = [pre 'RC_plot'];
fdir.lfp = [pre 'LFP'];
fdir.BRI = [pre 'BRI'];
fdir.Phase = [pre 'Phase'];
fdir.PSTH = [pre 'Psth'];
fdir.varXtime = [pre 'varXtime'];

checkdir(fdir);


%% all recording with broken electrode and units that were still included
broken_id = [12.5  13.5  25.5  28.5  29.5  30.5  44.5  45.5  46.5  47.5  ...
    48.5  49.5  51.5  59.5  60.5  66.5  67.5  68.5  69.5  70.5  71.5  ...
    78.5  80.5  81.5  82.5  91.5  92.5  93.5  98.5  99.5  100.5  101.5 ...
    102.5  103.5  111.5  112.5  113.5  116.5  117.5  118.5  119.5  125.5 ...
    126.5  135.5  136.5  137.5  138.5  139.5  144.5  145.5  146.5  147.5  ...
    148.5  151.5  152.5  155.5  160.5  161.5  162.5  163.5  164.5  165.5  ...
    166.5  167.5  168.5  169.5  174.5  175.5  176.5  177.5  189.5  190.5  ...
    191.5  192.5  193.5  194.5  195.5  196.5  197.5  198.5  199.5  200.5  ...
    205.5 207.5 211.5 213.5 219.5 237.5 238.5 239.5:241.5 253.5 254.5 257.5 ...
    64  65  66  115  116  124  138  139  142  143  144  145  158  159 ...
    160 161  168  169  179  180  181 182  183  186  187  188  196 ...
    197 198  199  206 208  214  235  244  254  255 259  260  265 ...
    266 267  268  269  272  275  281  291  292  293  308 309  312  313 ...
    314  315  326  327 ];
broken_excl_5HT = [115  116  187  196  197  198  214 281  308  309 ...
    [44, 71, 78, 11:13 66:70, 80:82, 101:103, 107:112, 135, 151:152, 160 161, ...
    175:177, 189:200, 212:216,  239:241 253 254 257]+0.5];
broken_excl_nacl = [115  116  187  198  199  206  208 214  235 ...
    244  259  260  265  266  267  268  269 272  275  281  308  309 ...
    [11:13, 24, 30, 45:49, 59, 60, 66:70,71, 8:82, 91:93, 98:103, 107:112, ...
    113, 116:119, 135, 136:139, 144:148, 151, 152, 160:164, 175:177, 189:200, ...
    212:216, 237 238 239:241]+0.5];
broken_incl_5HT_rest = broken_id(~ismember(broken_excl_5HT, broken_id));

%% load file directories
% open file
fileID = fopen(fname, 'r');
SU_dir = textscan(fileID, '%s'); F = SU_dir{1};
idx = find( cellfun(@isempty, strfind(F, '5HT') ) & ...
    cellfun(@isempty, strfind(F, 'NaCl') ));
 
F_base = F(idx);
F_drug = F(idx+1);



%% ------------------------------------------------------------------------

for i = 1:length(F_drug)
    
    fprintf('WORKING ON FILE %1i \n', i);
    %----------------------------------------------------------- load files
    
    if isempty(strfind(F_drug{i}, 'c2'))
        repstr = 'c1';
    else
        repstr = 'c2';
    end
    
    fname = F_base{i};
    fname_drug = F_drug{i};
    
    if ~exist(fname)
        continue
    end
    
    
    % load c1/2 and c0 ex files
    ex0 = loadCluster(fname);    ex2 = loadCluster(fname_drug);
    partypes = {ex0.exp.e1.type, ex0.exp.e2.type};
    
    
    if isempty(strfind(fname_drug, '5HT'))
        drugname = 'NaCl';
    else
        drugname = '5HT';
    end
    

    if isfield(ex0.Trials, 'ed')
        ed = ex0.Trials(1).ed;
    else
        ed =nan;
    end
    x0 = ex0.stim.vals.x0;
    y0 = ex0.stim.vals.y0;
    ecc = sqrt( x0^2 + y0^2 ); 
    dose = getDose(ex2);
    volt = getVolt(ex2);
    
    
    
    if isempty(strfind(fname, 'kaki'))
        idxa = 1;
        monkey = 'ma';
        id_off = 0;
    else
        idxa = 0;
        monkey = 'ka';
        id_off = 0.5;
    end
    
    fig_gen = [fname((19:42)+idxa) '_' fname_drug((37:42)+idxa) ...
        '_' partypes{1} 'x' partypes{2} ];

    
    %------------------------------------------------------------ ocularity
    for ocul = intersect( unique([ex0.Trials.me]), unique([ex2.Trials.me]) )
        
        kk = kk +1;
        
        %----------------------------------------------------- general info
        exinfo(kk).id = str2double(fname(14+idxa:17+idxa))+id_off;
        exinfo(kk).electrodebroken = any(broken_id == exinfo(kk).id);
        exinfo(kk).monkey = monkey;
        exinfo(kk).ismango = strcmp(monkey, 'ma');
        exinfo(kk).dose = dose;
        exinfo(kk).ed = ed;
        exinfo(kk).volt = volt;
        exinfo(kk).resistance = volt/dose;

        exinfo(kk).x0 = x0;                   exinfo(kk).y0 = y0;
        exinfo(kk).ecc = ecc;
                
        exinfo(kk).fname = fname;             exinfo(kk).fname_drug = fname_drug;
        exinfo(kk).ocul = ocul;               exinfo(kk).idi = idi;   % index indicating the same file
        exinfo(kk).drugname = drugname;
        exinfo(kk).date = getExDate(ex0);     exinfo(kk).date_drug = getExDate(ex2);
        
        exinfo(kk).param1 = partypes{1};      exinfo(kk).param2 = partypes{2};
        exinfo(kk).is5HT      = ~isempty(strfind(fname_drug, '5HT'));
        exinfo(kk).isadapt    = ~isempty(strfind(fname_drug, 'adapt'));
        exinfo(kk).isRC       = ~isempty(strfind(fname_drug, 'RC'));
        exinfo(kk).isc2       = strcmp(repstr, 'c2');
        exinfo(kk).cluster    = repstr;
        
        exinfo(kk).rsc = nan;         exinfo(kk).prsc = nan;
        exinfo(kk).rsc_drug = nan;    exinfo(kk).prsc_drug = nan;
        exinfo(kk).rsig = nan;        exinfo(kk).prsig = nan;
        exinfo(kk).rsig_drug = nan;   exinfo(kk).prsig_drug = nan;
        exinfo(kk).wdt = -1;    
        
        
        if exinfo(kk).isRC
            
            if isfield(ex0.stim.vals,'RCperiod')
                exinfo(kk).stimdur = ex0.stim.vals.RCperiod;
            else
                exinfo(kk).stimdur = 1;
            end
            add_RC = 'xRC';
        else
            add_RC = '';
        end
        
        
        %----------------------------------------------------- figure names
        
        switch ocul
            case -1
                figname = [fig_gen add_RC '_left_' drugname];
            case 0
                figname = [fig_gen add_RC '_both_' drugname];
            case 1
                figname = [fig_gen add_RC '_right_' drugname];
        end
              
        
        exinfo(kk).figname        = figname;
        exinfo(kk).figpath        = fullfile(fdir.TC, '\', [figname '_summary.fig']);
        exinfo(kk).fig_tc         = fullfile(fdir.TC, '\', [figname '_tc.fig']);
        exinfo(kk).fig_regl       = fullfile(fdir.Regression, '\', [figname '_regl.fig']);
        exinfo(kk).fig_raster     = fullfile(fdir.Raster, '\', [figname '_raster.fig']);
        exinfo(kk).fig_waveform   = fullfile(fdir.Waveform, '\', [figname '_waveform.fig']);
        
        exinfo(kk).fig_sdfs       = fullfile(fdir.RC, '\', [figname '_sdfs.fig']);
        
        exinfo(kk).fig_lfpPow     = fullfile(fdir.lfp, '\', [figname '_lfppow.fig']);
        exinfo(kk).fig_lfpSpec     = fullfile(fdir.lfp, '\', [figname '_lfpspec.fig']);
        exinfo(kk).fig_lfpAvgSpk   = fullfile(fdir.lfp, '\', [figname '_spktriglfp.fig']);
        
        
        exinfo(kk).fig_bri        = fullfile(fdir.BRI, '\', [figname '_bri.fig']);
        
        exinfo(kk).fig_ppszTraj   = fullfile(fdir.PPSZdev, '\', [figname '_devppsz_b4.fig']);
        exinfo(kk).fig_ppszHist   = fullfile(fdir.PPSZhist, '\', [figname '_histppsz.fig']);
        
        exinfo(kk).fig_phase   = fullfile(fdir.Phase, '\', [figname '_phase.fig']);
        exinfo(kk).fig_psth   = fullfile(fdir.PSTH, '\', [figname '_psth.fig']);
        
        exinfo(kk).fig_phasetf = fullfile(fdir.Phase, '\', [figname '_psth_tf.fig']);
        
        exinfo(kk).fig_varxtime = fullfile(fdir.Phase, '\', [figname '_varxtime.fig']);

        
    end
    
    % check whether electrodes were broken
    exinfo(kk).electrodebroken  = ismember(exinfo(kk).id, broken_id);
    
    
    % check whether electrodes were broken and excluded    
    if exinfo(kk).is5HT
        exinfo(kk).electrodebroken_excl = ismember(exinfo(kk).id, broken_excl_5HT);
        exinfo(kk).electrodebroken_incl_underrest = ismember(exinfo(kk).id, broken_incl_5HT_rest);
    else
        exinfo(kk).electrodebroken_excl = ismember(exinfo(kk).id, broken_excl_nacl);
        exinfo(kk).electrodebroken_incl_underrest = 0;
    end
    
    idi = idi+1;
    
end

exinfo = setPhaseSelTFexp( exinfo );
save('genInfo.mat', 'exinfo')
end




function checkdir(fdir)
fnames = fieldnames(fdir);
for i = 1:length(fnames)
    if ~exist(fdir.(fnames{i}), 'dir')
        mkdir(fdir.(fnames{i}));
    end
end
end



