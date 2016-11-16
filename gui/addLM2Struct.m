function exinfo = addLM2Struct( exinfo )


load('C:\Users\Corinna\Documents\CODE\CL_alwaysuseful\gui\linreg01.mat');

lat_std_t = 201:400;


for i = 1:length( exinfo )
    if exinfo(i).isRC
        if any(exinfo(i).id == [simlm.id]);
            exinfo(i).reg_slope = simlm(exinfo(i).id == [simlm.id]).std_slope;
            exinfo(i).reg_off  = simlm(exinfo(i).id == [simlm.id]).std_off;
                        
            exinfo(i).latcorrect_drug = exinfo(i).lat2Hmax_drug - ...
                ( exinfo(i).reg_slope.* mean(sqrt(exinfo(i).resvars_drug(lat_std_t))) - ...
                exinfo(i).reg_slope.* mean(sqrt(exinfo(i).resvars(lat_std_t))) ); 

        else
            exinfo(i).reg_off = 0;
            exinfo(i).reg_slope = 0;
        end
        
        
        
    end
    
end

