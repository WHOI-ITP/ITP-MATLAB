classdef LatitudeFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isnumeric(obj.args)
                error('ITP:valueError', ...
                    '"latitude" must be a numeric vector')
            end
            if length(obj.args) ~= 2
                error('ITP:valueError', ...
                    '"latitude" must contain exactly two values')
            end
            if ~all(obj.args >= -90 & obj.args <= 90)
                error('ITP:valueError', ...
                    '"latitude" must be in range -90 to 90')
            end
            if obj.args(2) <= obj.args(1)
                error('ITP:valueError', ...
                    '"latitude" values must be increasing')
            end
        end

        function query = value(obj)
            query = sprintf(...
                '(latitude >= %0.4f AND latitude <= %0.4f)', ...
                obj.args(1), obj.args(2));
        end
    end
end
