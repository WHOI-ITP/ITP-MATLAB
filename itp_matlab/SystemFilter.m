classdef SystemFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isnumeric(obj.args)
                error('"system" must be a numeric vector')
            end
        end

        function query = value(obj)
            query = '(system_number IN (';
            for i = 1:length(obj.args)
                query = [query, sprintf('%d,', obj.args(i))];
            end
            query(end) = [];
            query = [query, '))'];
        end
    end
end
