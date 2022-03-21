classdef DateTimeFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isnumeric(obj.args)
                error('"date_time" must be a numeric vector')
            end
            if length(obj.args) ~= 2
                error('"date_time" must contain exactly two values')
            end
            if obj.args(2) <= obj.args(1)
                error('End time must be later than start time')
            end
        end

        function query = value(obj)
            start_time = datestr(obj.args(1), 'yyyy-mm-ddTHH:MM:SS');
            end_time = datestr(obj.args(2), 'yyyy-mm-ddTHH:MM:SS');
            query = sprintf(...
                '(date_time >= %s AND date_time < %s)', ...
                start_time, end_time);
        end
    end
end
