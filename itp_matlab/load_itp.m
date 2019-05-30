function results = load_itp(varargin)
startTime = now;
p = inputParser;
addParameter(p, 'system', []);
addParameter(p, 'latitude', [-90 90]);
addParameter(p, 'longitude', [-180 180]);
addParameter(p, 'date_time', [datenum(2001,1,1) datenum(2100,1,1)]);
addParameter(p, 'pressure', [0 1000000]);
parse(p, varargin{:});

query = 'SELECT * FROM profiles';

if length(p.UsingDefaults) ~= 5
    query = [query, ' WHERE'];
end

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

directory = fileparts(mfilename('fullpath'));
db = mksqlite('open', fullfile(directory, 'itp.db'));
mksqlite('NULLasNaN', 1);
precision = mksqlite(db, 'SELECT name, precision FROM sensors');
results = mksqlite(db, query);

if length(results) > 5000
    error('%d results exceed maximum of 5000', length(results))
end

if notDefault('pressure', p)
    pressure = p.Results.pressure;
    pressureInd = find(strcmp({precision.name}, 'pressure'));
    if ~isempty(pressureInd)
        p = precision(pressureInd).precision;
        pressure = pressure * 10 .^ p;
    end
    pressureFilter = sprintf(' AND pressure >= %f AND pressure <= %f ', pressure);
else
    pressureFilter = '';
end

for i = 1:size(results, 1)
    results(i).serial_time = datenum(results(i).date_time, 'yyyy-mm-ddTHH:MM:SS');                          
    query = sprintf(['SELECT pressure/10.0 AS pressure, ',...
                            'temperature/10000.0 AS temperature, ',... 
                            'salinity/10000.0 AS salinity ',...
                     'FROM ctd ',...
                     'WHERE profile_id = %d %s ',...
                     'ORDER BY pressure'],...                        
                     results(i).id, pressureFilter);
    results(i).sensors = mksqlite(db, query);
end
results = rmfield(results, 'id');
fprintf('%d profiles returned in %0.2f seconds\n', length(results), (now-startTime)*24*60*60);
mksqlite(db, 'close');


function state = notDefault(field, parameters)
if any(strcmp(parameters.UsingDefaults, field))
    state = false;
else
    state = true;
end
