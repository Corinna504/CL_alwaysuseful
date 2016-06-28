function param = PlotProps()
%PlotProps specifies plot properties
%   Detailed explanation goes here

param.fillSign = true;

param.analysisOpts = {'choose analysis', 'compare TC', 'tuning curve', 'waveform','pupil size all', ...
    'pupil size onset', 'pupil size change', 'gain change',...
    'time course of spike rate', 'time course of gain change',...
    'time course of wave width',...
    'fano factor (CL)', ...
    'fano factor (Mitchel)', 'fano factor (Churchl)', 'lfp (time domain)', ...
    'lfp (frequ domain)', 'noise correlation', 'signal correlation', 'ALL: fano factor (Mitchel)'};

param.clusterOpts = {'choose cluster', 'c1', 'c1/c0', 'lfp'};

param.axisOpts = {...
    'phase selectivity', ...
    'r2 ag', 'r2 cg', 'r2 rg', 'a ag', 'a cg', 'a rg', ...
    'blank base', 'blank drug', 'blank diff', ...
    'c50 base', 'c50 drug', 'c50 diff', ...    
    'SMI', 'BRI ACF base', 'BRI ACF drug', ...
    'BRI ISI base', 'BRI ISI drug', ...
    'Osz alpha (8-10) base', 'Osz alpha (8-10) drug' , ...
    'Osz alpha diff', ...
    'Osz beta (10-30) base', 'Osz beta (10-30) drug' , ...
    'Osz beta diff', ...
    'Osz gamma (30-80) base', 'Osz gamma (30-80) drug' , ...
    'Osz gamma diff', ...
    'electrode depth', ...
    'change in mean resp', ...
    'latency base', 'latency drug', 'latency diff', ...
    'latency base corrected', 'latency drug corrected', 'latency diff corrected', ...
    'correction factor', ...
    'smallest response drug', 'smallest response', 'smallest response overall', ...
    'response duration', 'response duration drug', 'response duration diff', ...
    'latnoise', 'latnoise drug', 'latnoise diff',...
    'predicted latency', 'predicted latency drug', 'predicted latency diff', ...
    'predicted - true latency', 'predicted - true latency drug', ...    
    'pupil size base w1', 'pupil size drug w1', ...
    'pupil size base w2', 'pupil size drug w2', 'pupil size base w3', 'pupil size drug w3', ...
    'pupil size base w4', 'pupil size drug w4',...
    'cl gauss fit mu base', 'cl gauss fit mu drug', 'cl gauss fit mu diff', ...
    'cl gauss fit sig base', 'cl gauss fit sig drug', 'cl gauss fit sig diff', ...
    'cl gauss fit a base', 'cl gauss fit a drug', 'cl gauss fit a diff', ...
    'cl gauss fit off base', 'cl gauss fit off drug', 'cl gauss fit off diff', ...
    'cl gauss fit r2 base', 'cl gauss fit r2 drug', 'cl gauss fit r2 diff', ...
    'mean spike rate base', 'mean spike rate drug',...
    'mean spike rate diff', ...
    'mean spike rate variance base', 'mean spike rate variance drug',...
    'mean spike rate variance diff',...
    'mean spike count base', 'mean spike count drug',... 
    'mean spike count diff', ...
    'mean spike count variance base', 'mean spike count variance drug',...
    'mean spike count variance diff', ...
    'noise correlation', 'noise correlation drug', ...
    'noise correlation diff', ...
    'signal correlation', 'signal correlation drug', ...
    'signal correlation diff', ...
    'gain change', 'additive change', 'wave width', ...
    'experiment time', ...
    'tc ampl base', 'tc ampl drug', 'tc ampl diff',...
    'fano factor base', 'fano factor drug', 'fano factor diff', ...
    'fano factor fit base', 'fano factor fit drug', 'fano factor fit diff', ...
    'fano factor mitchel variance', 'fano factor mitchel bins', ...
    'r2', 'pupil size'};
% , 'spike field coherence'};

param.faceColorOpts = {'face color nothing', ...
    '[expInfo(incl_i).is5HT]', ...
    '[expInfo(incl_i).isadapt]',...
    '[expInfo(incl_i).isRC]',...
    'r2', 'gainchange', 'r2 gauss'};

param.edgeColorOpts = {'edge color nothing', 'ocularity'};

param.markerOpts = {'mark nothing', 'stimulus condition'};

param.markerfacecol = [1 0 0];

param.stimulicond = {'all stimuli cond', 'or', 'sf', 'co', 'sz', 'RC', 'adapt'};

param.eyeopts =  {'all', 'dominant eye', 'non-dominant eye'};

end

