function profiles = load_itp(db_path, varargin)
start_time = now;
p = inputParser;

addParameter(p, 'system', []);
addParameter(p, 'latitude', []);
addParameter(p, 'longitude', []);
addParameter(p, 'direction', []);
addParameter(p, 'date_time', []);
addParameter(p, 'month', []);
addParameter(p, 'pressure', []);
addParameter(p, 'max_results', 10000);
addParameter(p, 'extra_variables', []);
parse(p, varargin{:});

args = p.Results;
max_results = args.max_results;
pressure = args.pressure;
extra_variables = args.extra_variables;
args = rmfield(args, {'max_results', 'pressure'});
args = removeEmptyArgs(args);

query = build_query(args);
db = sqlite(db_path, 'readonly');
meta_data = fetch(db, query);
if size(meta_data, 1) > max_results
    error('ITP:excessResults', ...
        '%d results exceed maximum of %d', ...
        size(meta_data, 1), max_results)
end

profiles = collect_profiles( ...
    db, meta_data, pressure, extra_variables);

fprintf('%d profiles returned in %0.2f seconds\n',...
        length(profiles),...
        (now-start_time)*24*60*60);
close(db);


function args = removeEmptyArgs(args)
fields = fieldnames(args);
for i = 1:length(fields)
    if isempty(args.(fields{i}))
        args = rmfield(args, fields{i});
    end
end


function query = build_query(args)
query = 'SELECT * FROM profiles WHERE ';
fields = fieldnames(args);
for i = 1:length(fields)
    field = fields{i};
    values = args.(fields{i});
    filter_obj = pre_filter_factory(field, values);
    query = [query, filter_obj.value(), ' AND '];
end
if strcmp(query(end-4:end), ' AND ')
    query(end-4:end) = [];
elseif strcmp(query(end-6:end), ' WHERE ')
    query(end-6:end) = [];
end
query = [query, ' ORDER BY system_number, profile_number'];


function profiles = collect_profiles(db, meta_data, pressure, extra_vars)
ID = 1;
SYSTEM_NUMBER = 2;
PROFILE_NUMBER = 3;
DATE_TIME = 5;
LATITUDE = 6;
LONGITUDE = 7;
DIRECTION = 8;
PRESSURE = 1;
TEMPERATURE = 2;
SALINITY = 3;
NULL = 1E15;

profiles = repmat(Profile(), size(meta_data, 1), 1);
empty_profiles = false(size(meta_data, 1), 1);

for i = 1:size(meta_data, 1)
    id = meta_data{i, ID};
    profiles(i).serial_time = datenum(...
        meta_data{i, DATE_TIME}, 'yyyy-mm-ddTHH:MM:SS');
    if isa(meta_data{i, SYSTEM_NUMBER}, 'int64')
        profiles(i).system_number = double(meta_data{i, SYSTEM_NUMBER});
    else
        profiles(i).system_number = meta_data{i, SYSTEM_NUMBER};
    end    
    profiles(i).profile_number = double(meta_data{i, PROFILE_NUMBER});
    profiles(i).latitude = meta_data{i, LATITUDE};
    profiles(i).longitude = meta_data{i, LONGITUDE};
    profiles(i).direction = meta_data{i, DIRECTION};
    if ~isempty(pressure)
        pressure_str = PressureFilter(pressure).value();
    else
        pressure_str = '';
    end
    query = sprintf([...
        'SELECT ifnull(pressure/10000.0, %f) AS pressure, '...
        'ifnull(temperature/10000.0, %f) AS temperature, '... 
        'ifnull(salinity/10000.0, %f) AS salinity '...
        'FROM ctd WHERE profile_id = %d %s ORDER BY pressure'], ...
        NULL, NULL, NULL, id, pressure_str);

    data = fetch(db, query);
    if isempty(data)
        % the pressure filter may eliminate all the samples
        % in that case, remove the profile
        empty_profiles(i) = true;
        continue
    end

    ctd = double(cell2mat(data));
    ctd(ctd==NULL) = NaN;
    
    profiles(i).pressure = ctd(:, PRESSURE);
    profiles(i).temperature = ctd(:, TEMPERATURE);
    profiles(i).salinity = ctd(:, SALINITY);
    if ~isempty(extra_vars)
        profiles(i).extra_variables = load_extra_variables(...
            db, id, extra_vars, pressure_str, NULL);
    end
end
profiles(empty_profiles) = [];

function extra_vars_struct = load_extra_variables( ...
    db, id, extra_vars, pressure_str, NULL)
extra_vars_struct = [];
for i = 1:length(extra_vars)
    sql = sprintf([...
        'SELECT ifnull(value/10000.0, %f) val FROM ctd ', ...
        'LEFT JOIN other_variables ', ...
    	'ON ctd.id == other_variables.ctd_id AND variable_id == ', ...
    	'(SELECT id FROM variable_names WHERE name == "%s") ', ...
    	'WHERE ctd.profile_id == %d %s ', ...
    	'ORDER BY pressure'],...
        NULL, extra_vars{i}, id, pressure_str);
    this_variable = cell2mat(fetch(db, sql));
    this_variable(this_variable == NULL) = NaN;
    if ~all(isnan(this_variable))
        extra_vars_struct.(extra_vars{i}) = this_variable;
    end
end
