function [gridX, gridY, expstrt] = getGridPosition( ex )
% returns recording position on the scalp and the experiment start
% identified as the start of the first experiment (i.e. TrialStart)


if isfield(ex.setup, 'gridX')
    gridX = ex.setup.gridX;
    gridY = ex.setup.gridY;
    expstrt = ex.Trials(1).TrialStart;
elseif  isfield(ex.setup, 'Left_Hemisphere_gridX')
    gridX = ex.setup.Left_Hemisphere_gridX;
    gridY = ex.setup.Left_Hemisphere_gridY;
    expstrt = ex.Trials(1).TrialStart;
end


end


% CODE TO USE FOR THE ASSIGNEMT WITHIN SESSIONS OR THE WHOLE RECORDING TIME
% for kk = 1:length(exinfo)
%     
%     i_samepos = find(exinfo(kk).gridX == gx & exinfo(kk).gridY == gy);
%     i_samepos = intersect(i_samepos, find([exinfo.expstrt] <= exinfo(kk).expstrt ...
%         & strcmp({exinfo.monkey}, exinfo(kk).monkey)));
%     
%     
%     exinfo(kk).dt_first = exinfo(kk).expstrt - min([exinfo(i_samepos).expstrt]);
%     
%    if length(i_samepos)>1
%         dt_cum = findpeaks([-1, [exinfo(i_samepos).dt_cum_session], -1]);
%         
%         t = [exinfo(i_samepos(1:end-1)).expstrt];
%         exinfo(kk).dt_last = min(exinfo(kk).expstrt-t);
%             
%     else
%         dt_cum = 0;
%         exinfo(kk).dt_last = 0;
%     end
%     exinfo(kk).dt_cum_pos = sum(dt_cum);
%     
% end
