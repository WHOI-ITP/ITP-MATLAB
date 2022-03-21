classdef DirectionFilter < SqlFilter
    methods
        function check(obj)
            check@SqlFilter(obj)
            if ~isstr(obj.args)
                error('"direction" must be a string')
            end
            if ~any(strcmp({'up', 'down'}, obj.args))
                error('"direction" must be either "up" or "down"')
            end
        end

        function query = value(obj)
            query = sprintf('(direction = "%s")', obj.args);
        end
    end
end
