function info = addLM2Struct( info )


load('C:\Users\Corinna\Documents\CODE\CL_alwaysuseful\gui\linreg01.mat');

lat_std_t = 201:400;


for i = 1:length( info )
    if info(i).isRC
        if any(info(i).id == [simlm.id]);
            info(i).reg_slope = simlm(info(i).id == [simlm.id]).std_slope;
            info(i).reg_off  = simlm(info(i).id == [simlm.id]).std_off;
                        
            info(i).latcorrect_drug = info(i).lat2Hmax_drug - ...
                ( info(i).reg_slope.* mean(sqrt(info(i).resvars_drug(lat_std_t))) - ...
                info(i).reg_slope.* mean(sqrt(info(i).resvars(lat_std_t))) ); 

        else
            info(i).reg_off = 0;
            info(i).reg_slope = 0;
        end
        
        
        
    end
    
end

