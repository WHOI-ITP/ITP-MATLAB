classdef SqlFilter
    properties
        args
    end
    
    methods
        function obj = SqlFilter(args)
            obj.args = args;
            obj.check()
        end

        function check(obj)
            if isempty(obj.args)
                error('ITP:valueError', ...
                    'Argument cannot be empty')
            end
        end

        function query = value(obj)
            error('ITP:notImplemented', ...
                'Function must be implemented in subclass')
        end
        
    end
end
