function f1f0 = getPhaseSelectivity( ex, varargin )
% returns the well established f1 over f0 in an experiment were temporal
% frequency and phase were manipulated
%
%
% 
% @Corinna Lorenz, 22.08.2016


p_flag = false;     stim = 'tf';
k=1;
while k<=length(varargin)
    switch varargin{k}
        case 'plot'
            p_flag = varargin{k+1};
        case 'stim'
            stim = varargin{k+1};
            
    end
    k=k+1;
end



%% 
% sdfs kernel 
kern = ones(40,1)/40;

% spontaneoue activtiy from blank trials
blanktrials = ex.Trials([ex.Trials.Reward]==1 & [ex.Trials.(stim)]>100);
if ~isempty(blanktrials)
    psth_blank = getPSTH(blanktrials); spontresp = mean(psth_blank);
else
    spontresp = 0;
end

% correct trials only
ex.Trials = ex.Trials([ex.Trials.Reward]==1 & [ex.Trials.(stim)]<1000);

allstim = unique([ex.Trials([ex.Trials.(stim)]<1000).(stim)]);
if strcmp(stim, 'tf')
    tf =  allstim;
else
    tf = repmat(ex.stim.vals.tf, size(allstim));
end



% f1 from fourier transformation and f0 as mean - spont response
for k = 1:length(allstim)
    
    %1.first derive the psth for all trials with particular stimuli
    trials = ex.Trials( [ex.Trials.(stim)] == allstim(k));
    
    [psth, t] = getPSTH(trials); 
    psth = psth - spontresp;
    psth(psth<0) = 0;
    
    try

        sdfs(k,1:length(psth)) = filter(kern,1, psth);
        [a(k),f0(k)] = f1f0Sine (sdfs(k,1:length(psth)), t, tf(k));
        
    catch
       disp('') 
    end
 
end

t = 0.001:0.001:length(sdfs)/1000;
f1 = a*2; % f1 is the amplitude

% use the highest mean response to compute 
[~, i] = max(f0);
f1f0 = f1(i)/f0(i);


if p_flag
    %%% plot results
    figure('Position', [   836   247   545   701]);
    
   offset = max(max(sdfs));
    for k = 1:length(allstim)
        subplot(length(allstim), 2, (k*2)-1)
        plot(t, sin(t *pi*2*tf(k) ) * offset/2+ offset/2, 'Color', [0.8 0.8 0.8]); hold on; 
        plot(t, sdfs(k,:), 'b'); 
        title(num2str(allstim(k)));
        ylabel('spk/s'); 
        xlim([t(1) t(end)])
    end
    
    
    xticklab = cellfun(@(x) sprintf('%1.1f',x), num2cell(allstim),'UniformOutput' ,false);    
    
    subplot(2, 2, 2);
    plot(1:length(allstim), a./f0);
    xlabel tf; ylabel f0; xlim([1 length(allstim)]);
    set(gca, 'XTick', 1:length(allstim), 'XTickLabel', xticklab );
    title(sprintf('stim @maxresp: %1.1f, f1f0: %1.3f', allstim(i), f1f0));

    
    subplot(2,2,4)
    plot(1:length(allstim), a); hold on;
    plot(1:length(allstim), f0); legend('f1', 'f0');
    
    xlabel stim; xlim([1 length(allstim)]);
    set(gca, 'XTick', 1:length(allstim), 'XTickLabel', xticklab );
    
    
end
end


