classdef ExtraVariableFilter < SqlFilter
    % Note that this is a pre-filter. Its purpose is to only return 
    % profiles that have at least one of the extra variables.
    properties
        valid = {'dissolved_oxygen', 'north', 'nacm', 'vert', 'east', ...
            'cdom', 'par', 'chlorophyll_a', 'turbidity'};
    end
    methods
        function check(obj)
            check@SqlFilter(obj)
            
            if ~iscell(obj.args)
                error('"extra_variables" must be a cell array')
            end
            for i = 1:length(obj.args)
                if ~any(strcmp(obj.args{i}, obj.valid))
                    error('Invalid "extra_variable" %s', obj.args{i})
                end
            end
        end

        function query = value(obj)
            query = ['(profiles.id IN (SELECT profile_id FROM ' ...
                'profile_extra_variables INNER JOIN variable_names ' ...
                'ON profile_extra_variables.variable_id == ' ...
                'variable_names.id WHERE variable_names.name IN ('];
            for i = 1:length(obj.args)
                query = [query, sprintf('"%s",', obj.args{i})];
            end
            query(end) = [];
            query = [query, ')))'];
        end
    end
end
