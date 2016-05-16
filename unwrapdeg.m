function [ ang_out, add_val ] = unwrapdeg( ang_in , add_val)
% unwrapdeg works like unwrap with radians
% ang_out is the 180 degree shift in order to keep it in range of [0,180]
%
%@CL


if ang_in > 180
    ang_out = ang_in -180;
    add_val = add_val-180;

elseif  ang_in < 0
    ang_out = ang_in +180;
    add_val = add_val+180;
else
    ang_out = ang_in;
end


end

