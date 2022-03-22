classdef MonthFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isnumeric(obj.args)
                error('ITP:valueError', ...
                    '"month" must be a numeric vector')
            end
            if ~all(rem(obj.args, 1) == 0)
                error('ITP:valueError', ...
                    '"month" values must be whole numbers')
            end
            if ~all(ismember(obj.args, 1:12))
                error('ITP:valueError', ...
                    '"month" must be in the range [1, 12]')
            end
        end

        function query = value(obj)
            months = sprintf('"%02d",', obj.args);
            months(end) = [];
            query = sprintf(...
                '(strftime("%%m", date_time) IN (%s))', ...
                months);
        end
    end
end
