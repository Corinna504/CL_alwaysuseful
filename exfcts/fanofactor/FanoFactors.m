function [ ff1, ff1_fit, mitchel, church ] = FanoFactors( ex, Mn, Vars, param1 )
% all kind of fano factor calculations are performed
% - casual mn/vars
% - power law fit
% - mitchel way
% - churchland way


%------------------------------------------------------ Fano Factor
ff1 = ( Mn ./ Vars );
ff1 = nanmean(ff1);

[FitPa, ~,~,~,~] = FitPower( Mn , Vars);
ff1_fit = FitPa.exponent;

%------------------------------------------------------- Mitchel FF
[mitchel.mn, mitchel.sem, mitchel.bindat] = Mitcheletal(ex.Trials, param1);

%------------------------------------------------------- Churchl FF
church = Churchlandetal( ex.Trials );
    



end

