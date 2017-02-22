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

