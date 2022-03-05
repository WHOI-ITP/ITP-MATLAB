function profiles = load_itp(db_path, varargin)
startTime = now;
p = inputParser;
addParameter(p, 'system', ['*']);
addParameter(p, 'latitude', [-90 90]);
addParameter(p, 'longitude', [-180 180]);
addParameter(p, 'direction', []);
addParameter(p, 'date_time', [0 datenum(2100,1,1)]);
addParameter(p, 'month', []);
addParameter(p, 'pressure', [0 1000000]);
addParameter(p, 'max_results', 10000);
addParameter(p, 'extra_variables', []);
parse(p, varargin{:});

NANVAL = 2^30;

query = 'SELECT * FROM profiles WHERE';

if notDefault('system', p)
    system_filter = '(';
    for i = 1:length(p.Results.system)
        system_filter = [system_filter, sprintf(' system_number = %d OR', p.Results.system(i))];
    end
    system_filter = [system_filter(1:end-3), ') AND'];
    query = [query, system_filter];
end

if notDefault('latitude', p)
    latFilter = sprintf(' (latitude > %f AND latitude < %f) AND', p.Results.latitude);
    query = [query, latFilter];
end

if notDefault('longitude', p)
    lon = p.Results.longitude;
    if lon(2) < lon(1)
        logical = 'OR';
    else
        logical = 'AND';
    end
    lonFilter = sprintf(' (longitude > %f %s longitude < %f) AND', lon(1), logical, lon(2));
    query = [query, lonFilter];
end

if notDefault('direction', p)
    dirFilter = sprintf(' direction = "%s" AND', p.Results.direction);
    query = [query, dirFilter];
end

if notDefault('date_time', p)
    time = {datestr(p.Results.date_time(1), 'yyyy-mm-ddTHH:MM:SS'), datestr(p.Results.date_time(2), 'yyyy-mm-ddTHH:MM:SS')};
    timeFilter = sprintf(' date_time >= "%s" AND date_time < "%s" AND', time{1}, time{2});
    query = [query, timeFilter];
end

if notDefault('month', p)
    monthFilter = sprintf(' strftime("%%m", date_time) IN (%s) AND', ...
        format_date_range(p.Results.month));
    query = [query, monthFilter];
end

if notDefault('extra_variables', p)
    extra_names = '';
    extra_variables = make_cell(p.Results.extra_variables);

    for i = 1:length(extra_variables)
        extra_names = [extra_names, '"', extra_variables{i}, '"', ','];
    end
    extra_names(end) = '';
    sql = sprintf([...
        ' profiles.id IN (SELECT profile_id FROM profile_extra_variables ', ...
        'INNER JOIN variable_names ', ...
        'ON profile_extra_variables.variable_id == variable_names.id ', ...
        'WHERE variable_names.name IN (%s)) AND']...
    , extra_names);
    query = [query, sql];
end

if strcmp(query(end-3:end), ' AND')
    query = query(1:end-4);
end

query = [query, ' ORDER BY system_number, profile_number'];

db = sqlite(db_path, 'readonly');
results = fetch(db, query);

if length(results) > p.Results.max_results
    error('%d results exceed maximum of %d', length(results), p.Results.max_results)
end

if notDefault('pressure', p)
    pressure = p.Results.pressure;
    pressure = pressure * 1E4;
    pressure_filter = sprintf(' AND pressure >= %f AND pressure <= %f ', pressure);
else
    pressure_filter = '';
end

% Query the individual profiles
profiles = repmat(Profile(), length(results), 1);
emptyProfiles = false(length(results), 1);

for i = 1:size(results, 1)
    profiles(i).serial_time = datenum(results{i,5},...
                                    'yyyy-mm-ddTHH:MM:SS');
    profiles(i).system_number = results{i,2};
    profiles(i).profile_number = results{i,3};
    profiles(i).latitude = results{i,6};
    profiles(i).longitude = results{i,7};
    profiles(i).direction = results{i,8};

    query = [
        'SELECT ifnull(pressure/10000.0, -9999.99) AS pressure, ',...
        'ifnull(temperature/10000.0, -9999.99) AS temperature, ',... 
        'ifnull(salinity/10000.0, -9999.99) AS salinity ',...
        'FROM ctd '];

    query = [query,...
        sprintf('WHERE profile_id = %d %s ORDER BY pressure',...
        results{i,1}, pressure_filter)];
    ctd = cell2mat(fetch(db, query));
    ctd(ctd==-9999.99) = NaN;
    if size(ctd, 1) == 0
        emptyProfiles(i) = true;
        continue
    end
    profiles(i).pressure = ctd(:,1);
    profiles(i).temperature = ctd(:,2);
    profiles(i).salinity = ctd(:,3);
    
    if notDefault('extra_variables', p)
        for j = 1:length(extra_variables)
            sql = sprintf([...
                'SELECT ifnull(value/10000.0, -9999.99) val FROM ctd ', ...
                'LEFT JOIN other_variables ', ...
            	'ON ctd.id == other_variables.ctd_id AND variable_id == ', ...
            	'(SELECT id FROM variable_names WHERE name == "%s") ', ...
            	'WHERE ctd.profile_id == %d ', ...
            	'ORDER BY pressure'],...
                extra_variables{j}, results{i,1});
            this_variable = cell2mat(fetch(db, sql));
            this_variable(this_variable==-9999.99) = NaN;
            if ~all(isnan(this_variable))
                profiles(i).other_variables.(extra_variables{j}) = this_variable;
            end
        end
    end
    
end

% Remove empty profiles
profiles = profiles(~emptyProfiles);

fprintf('%d profiles returned in %0.2f seconds\n',...
        length(profiles),...
        (now-startTime)*24*60*60);
close(db);


function output = format_date_range(input)
if ~isfloat(input)
    error('Date range must be a vector of integers');
end
output = sprintf('"%02d",', input);
output(end) = [];


function cell_array = make_cell(input)
if ischar(input)
    cell_array = {input};
elseif iscell(input)
    cell_array = input;
else
    error('Unknown input type')
end


function state = notDefault(field, parameters)
if any(strcmp(parameters.UsingDefaults, field))
    state = false;
else
    state = true;
end