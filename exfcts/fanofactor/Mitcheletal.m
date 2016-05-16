function [ mitchel_mn, mitchel_sem, bindata] = Mitcheletal( Trials, param1 )
%Mitcheletal
% Trials without reward are excluded. Each neuron in each condition is one
% date point.
%


nbin = 5;


Trials  = getSpkPerBin(Trials, nbin);
mSpk    = getMeanSpkPerCond(Trials, param1);


mnbinspk = vertcat(mSpk.mnspk);
varbinspk = vertcat(mSpk.varspk);


%------------------------------------------------------------- Mitchel Norm

mnbinspk       = reshape(mnbinspk(:, 1:4), length(mnbinspk)*4, 1);
varbinspk      = reshape(varbinspk(:, 1:4), length(varbinspk)*4, 1);



[mnspkvar, bindata] = mitchelPlot(mnbinspk, varbinspk);    

mitchel_mn  = mnspkvar(:,1);
mitchel_sem = mnspkvar(:,2);

end



function Trials = getSpkPerBin(Trials, nbin)
% returns spikes in each trial
long_flag = 0;

for n = 1:length(Trials)
    
    t_spks = Trials(n).Spikes; % time of spike occurance
    t_strt = Trials(n).Start - Trials(n).TrialStart; % frame start times
    if Trials(n).adapt
        t_strt = t_strt(t_strt > Trials(n).adaptationDuration);
    end
    
    t_strt(end+1) = t_strt(end) + mean(diff(t_strt));
    
    % steps of 100ms
    for bin_i = 1:nbin
        s(bin_i) = 0.15*(bin_i-1)+t_strt(1); % align for the last 400 msec
        e(bin_i) = s(bin_i)+0.15;
        
        if e(bin_i) > t_strt(end)
            e(bin_i) = t_strt(end); 
        end
        spkperbin(bin_i) = sum( t_spks>=s(bin_i) & t_spks<e(bin_i) ) ;
        
    end
    
    if e(bin_i) < t_strt(end)
        long_flag = 1;
    end
    
    Trials(n).spkperbin = spkperbin;
    Trials(n).lastBinDur = e(end)-s(end);
end

if long_flag
    disp('trials took longer than 500 ms');
end

end


function mSpk = getMeanSpkPerCond(Trials, param)
% evaluates mean and variance of each time bin over all neurons and
% conditions

eval(['parVal = unique([Trials.' param ']);']);

for i = 1:length(parVal)
    
    eval(['idx = find([Trials.' param '] == parVal(i) );']);
    
    mSpk(i).parVal = parVal(i);
    
    mSpk(i).mnspk = mean(vertcat(Trials(idx).spkperbin), 1);
    mSpk(i).varspk = var(vertcat(Trials(idx).spkperbin), 0, 1);
    mSpk(i).lastBinDur = vertcat(Trials(idx).lastBinDur);
    
    
    
    if length(mSpk(i).mnspk) < 5
        error('too little bins');
    end
    
    for kk = 1:5
        mn(i,kk) = mSpk(i).mnspk(kk);
        vr(i,kk) = mSpk(i).varspk(kk);
    end
    
end

end


function [mnspkvar, dat] = mitchelPlot(mn, vr)
%mitchelPlot
% formally plotted a graph but now only calculates the histographic
% inforamtion



binranges = [0.1 0.1778 0.31 0.5623 1 1.7783 3.10 5.6234 10 20]; % adopt from Mitchel et al. Fig 3
axis_i = [1:2:9, 10];
    

% put data into bins
[bincounts, ind] = histc(mn, binranges);

% get mean of variance in each bin 
for bini = 1:length(binranges)-1
    dat(bini) = {vr(ind==bini)};
    mnspkvar(bini, 1) = mean(vr(ind==bini));
    mnspkvar(bini, 2) = 2 * (std(vr(ind==bini)) / length(vr(ind==bini))); %SEM
end

end

