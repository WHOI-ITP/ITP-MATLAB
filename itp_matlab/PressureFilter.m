classdef PressureFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isnumeric(obj.args)
                error('ITP:valueError', ...
                    '"pressure" must be a numeric vector')
            end
            if length(obj.args) ~= 2
                error('ITP:valueError', ...
                    '"pressure" must contain exactly two values')
            end
            if obj.args(2) <= obj.args(1)
                error('ITP:valueError', ...
                    '"pressure" values must be increasing')
            end
        end

        function query = value(obj)
            query = sprintf(...
                'AND (pressure >= %0.4f AND pressure <= %0.4f)', ...
                obj.args(1)*1E4, obj.args(2)*1E4);
        end
    end
end
