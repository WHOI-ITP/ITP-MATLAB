function results = load_itp(path, varargin)
startTime = now;
p = inputParser;
addParameter(p, 'system', ['*']);
addParameter(p, 'latitude', [-90 90]);
addParameter(p, 'longitude', [-180 180]);
addParameter(p, 'date_time', [0 datenum(2100,1,1)]);
addParameter(p, 'pressure', [0 1000000]);
addParameter(p, 'max_results', 10000); 
parse(p, varargin{:});

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
    latFilter = sprintf(' latitude > %f AND latitude < %f AND', p.Results.latitude);
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

if notDefault('date_time', p)
    time = {datestr(p.Results.date_time(1), 'yyyy-mm-ddTHH:MM:SS'), datestr(p.Results.date_time(2), 'yyyy-mm-ddTHH:MM:SS')};
    timeFilter = sprintf(' date_time BETWEEN "%s" AND "%s"', time{1}, time{2});
    query = [query, timeFilter];
end

if strcmp(query(end-3:end), ' AND')
    query = query(1:end-4);
end

query = [query, ' ORDER BY system_number, profile_number'];

db = mksqlite('open', path);
mksqlite('NULLasNaN', 1);
results = mksqlite(db, query);

if length(results) > p.Results.max_results
    error('%d results exceed maximum of %d', length(results), p.Results.max_results)
end

if notDefault('pressure', p)
    pressure = p.Results.pressure;
    pressure = pressure * 1E4;
    pressureFilter = sprintf(' AND pressure >= %f AND pressure <= %f ', pressure);
else
    pressureFilter = '';
end

for i = 1:size(results, 1)
    results(i).serial_time = datenum(results(i).date_time, 'yyyy-mm-ddTHH:MM:SS');
    query = [
        'SELECT pressure/10000.0 AS pressure, ',...
        'temperature/10000.0 AS temperature, ',... 
        'salinity/10000.0 AS salinity ',...
        'FROM ctd '];

    query = [query,...
        sprintf('WHERE profile_id = %d %s ORDER BY pressure',...
        results(i).id, pressureFilter)];
    ctd = mksqlite(db, query);
    results(i).pressure = [ctd.pressure];
    results(i).temperature = [ctd.temperature];
    results(i).salinity = [ctd.salinity];
end
%results = rmfield(results, {'id', 'file_name', 'date_time', 'n_depths'});
fprintf('%d profiles returned in %0.2f seconds\n', length(results), (now-startTime)*24*60*60);
mksqlite(db, 'close');


function query = build_profile_query(other_variables)
query = [
    'SELECT pressure/10000.0 AS pressure, ',...
    'temperature/10000.0 AS temperature, ',... 
    'salinity/10000.0 AS salinity '];

for i = 1:length(other_variables)
    query = [query, sprintf(', v%d.value/10000.0 AS %s ', i, other_variables(i).name)];
end
query = [query, 'FROM ctd '];
for i = 1:length(other_variables)
    query = [query, ...
        sprintf('LEFT JOIN other_variables v%d ON ctd.id == v%d.ctd_id AND v%d.variable_id == %d ',...
        i, i, i, other_variables(i).id)];
end


function state = notDefault(field, parameters)
if any(strcmp(parameters.UsingDefaults, field))
    state = false;
else
    state = true;
end
