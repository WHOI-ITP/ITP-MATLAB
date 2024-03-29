classdef Profile
    properties
        system_number
        profile_number
        latitude
        longitude
        direction
        serial_time
        pressure
        temperature
        salinity
        extra_variables
    end
    
    methods
        function out = datetime(obj)
            out = NaT(size(obj));
            for i = 1:length(obj)
                out(i) = datetime(...
                    obj(i).serial_time, 'ConvertFrom', 'datenum');
            end
        end
        function out = height(obj)
            out = gsw_z_from_p(obj.pressure, obj.latitude);
        end
        function out = depth(obj)
            out = -obj.height();
        end
        function out = absolute_salinity(obj)
            out = gsw_SA_from_SP(...
                obj.salinity,...
                obj.pressure,...
                obj.longitude,...
                obj.latitude...
            );
        end
        function out = conservative_temperature(obj)
            out = gsw_CT_from_t(...
                obj.absolute_salinity(),...
                obj.temperature,...
                obj.pressure...
            );
        end
        function out = potential_density(obj, p_ref)
            if ~exist('p_ref', 'var')
                p_ref = 0;
            end
            out = gsw_rho(...
                obj.absolute_salinity(),... 
                obj.conservative_temperature(),... 
                p_ref...
            );
        end
        function out = potential_temperature(obj, p_ref)
            if ~exist('p_ref', 'var')
                p_ref = 0;
            end
            out = gsw_pt_from_t(...
                obj.absolute_salinity(),...
                obj.temperature,...
                obj.pressure,...
                p_ref...
            );
        end
    end
end