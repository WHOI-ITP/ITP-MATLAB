classdef LongitudeFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isnumeric(obj.args)
                error('"longitude" must be a numeric vector')
            end
            if length(obj.args) ~= 2
                error('"longitude" must contain exactly two values')
            end
            if ~all(obj.args >= -180 & obj.args <= 180)
                error('"longitude" must be in range -180 to 180')
            end
        end

        function query = value(obj)
            if obj.args(2) < obj.args(1)
                logical = 'OR';
            else
                logical = 'AND';
            end

            query = sprintf(...
                '(longitude >= %0.4f %s longitude <= %0.4f)', ...
                obj.args(1), logical, obj.args(2));
        end
    end
end
