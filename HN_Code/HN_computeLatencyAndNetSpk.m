function res = HN_computeLatencyAndNetSpk(res,ex)

% takes the output from PlotRevCorAny_tue, 'res' and ex file to compute
% net-spikes and latency of the orientation selective response.
% If res=[], this function calls PlotRevCorAny_tue.
%
% 10/12/15  hn:   wrote it


if isempty(res) 
%     res = HN_PlotRevCorAny_tue(ex,'times',[-200:1600],'sdfw',40, 'noplot');
    res = PlotRevCorAny_tue(ex,'times',[-200:1600],'sdfw',40, 'noplot');
end
   
if isfield(res, 'vars')
%     res =  HN_newLatency(res);  % changed cl  11/11/15
    res =  CL_newLatency(res);  % changed @CL 22.01.2016 
    
    
    
%     % compute latency old, replaced by newLatency (s.o.)
%     vars = sqrt(res.vars);
%     vars = vars-mean(vars(1:20));
%     idx = find((vars)>=max((vars))/2);
% 
%     lat = idx(1);
%     res.latencyToHalfMax = res.delays(lat);



%     if isfield(res, 'latencyToHalfMax')
        
        
        % compute net spikes-------------------------------------------------------
        y = res.sdfs.nspk./res.sdfs.n;
        N = res.sdfs.n;
        for n = 1:length(res.sdfs.extras)
            y = [y; res.sdfs.extras{n}.nspk/res.sdfs.extras{n}.n];
            N = [N; res.sdfs.extras{n}.n];
        end
        
        % mean # of spikes per frame across all frames (I believe)
        % note: nspk gives us all spikes that are used in the analysis, i.e. spikes
        % are counted several times because of overlapping analysis windows
        mn = sum(y.*N)/sum(N);
        y1 = y-mn;  % this now gives me the deviation around the mean response
        
        
        % I couldn't wrap my head around how to compute the mean number of spikes/frame
        % without going via the SDF, so I do this via the sdf;
        for nd = 1:size(res.y,1)
%             for nd = 1:size(res.y,2) %hn version
            mn_resp(nd) = mean(squeeze(res.y(nd,1,:)))*res.sdfs.n(nd);
        end
        idx = find([res.times]>=res.delays(1) & [res.times]<=res.delays(end));
        
        % add values for extra stimuli (blank)
        extra_x=[];
        for n = 1: length(res.sdfs.extras)
            mn_resp =[mn_resp, mean(res.sdfs.extras{n}.sdf(idx)) * res.sdfs.extras{n}.n];
            extra_x(n) = n*1000+min(res.sdfs.x);
        end
        % mean response in spikes/sec
        mn_resp = sum(mn_resp)/sum(N);
        mn_resp = mn_resp/ex.setup.refreshRate;
        
        
        % added by CL on Feb, 17th 
        if isfield(ex.stim.vals,'RCperiod') && ex.stim.vals.RCperiod>1
            mn_resp = mn_resp / ex.stim.vals.RCperiod;
        end
        
        % net spikes per frame
        nspk = y1+mn_resp;
        x = [res.sdfs.x; extra_x];
        
        % format the output-------------------------------------------------------
%         figh_sdf = res.figa;
%         figh_slice= res.figb;
        fieldNames = {'calctime','nbad','figa','labela','labelb','bestdelay','figb','timeoff','alltriggers'};
        for n = 1:length(fieldNames)
            if isfield(res,fieldNames{n})
                res = rmfield(res,fieldNames{n});
            end
        end
        res.mean_resp = mn_resp;
        res.netSpikesPerFrame = nspk(1:length(nspk)-length(res.sdfs.extras));
        
        res.netSpikesPerFrameBlank = nspk(length(nspk)-length(res.sdfs.extras)+1:end);
%         res.netSpikesPerFrameBlank = nspk(length(nspk)-length(res.sdfs.extras):end);

        res.or = x(1:length(nspk)-length(res.sdfs.extras));
        
%     end
    
end


end
