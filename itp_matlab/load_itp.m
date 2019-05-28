function out = load_itp(varargin)
startTime = now;
p = inputParser;
addParameter(p, 'system', [1:1000]);
addParameter(p, 'latitude', [-90 90]);
addParameter(p, 'longitude', [-180 180]);
addParameter(p, 'date_time', [datenum(2001,1,1) datenum(2100,1,1)]);
addParameter(p, 'pressure', [0 5000]);
parse(p, varargin{:});

query = 'SELECT * FROM profiles';

if length(p.UsingDefaults) ~= 5
    query = [query, ' WHERE '];
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

db = mksqlite('open', 'C:\Projects\ITP-Python\itp_python\itp.db');
mksqlite('NULLasNaN', 1);
results = mksqlite(db, query);

if length(results) > 5000
    error('%d results exceed maximum of 5000', length(results))
end

if notDefault('pressure', p)
    pressureFilter = sprintf(' AND pressure >= %f and pressure <= %f ', p.Results.pressure);
else
    pressureFilter = ' ';
end

out = [];

for i = 1:size(results, 1)
    out(i).system_number = results(i).system_number;
    out(i).profile_number = results(i).profile_number;
    out(i).date_time = results(i).date_time;
    out(i).latitude = results(i).latitude;
    out(i).longitude = results(i).longitude;
    out(i).date_time = results(i).date_time;
    
                                      
    sql = sprintf('SELECT pressure, temperature, salinity FROM ctd WHERE profile_id = %d ORDER BY pressure',...
                  results(i).id);
    samples = mksqlite(db, sql);
    out(i).sensors.pressure = [samples.pressure]';
    out(i).sensors.temperature = [samples.temperature]';
    out(i).sensors.salinity = [samples.salinity]';
    
%     other_sensors = mksqlite(db, sprintf(['SELECT DISTINCT sensor_id, name from ctd ' ...
%                                           'LEFT JOIN sensor_names ON other_sensors.sensor_id = sensor_names.id ' ...
%                                           'LEFT JOIN other_sensors ON ctd.id = other_sensors.ctd_id ' ...
%                                           'where profile_id = %d and sensor_id is not NULL'], results(i).profile_number));
    other_sensors = mksqlite(db, sprintf(['select DISTINCT sensor_names.id, sensor_names.name from other_sensors '...
                                          'INNER JOIN ctd on ctd.profile_id = %d and ctd.id = other_sensors.ctd_id '...
                                          'INNER JOIN sensor_names on sensor_names.id = other_sensors.sensor_id'], results(i).profile_number));

        
    for s = 1:length(other_sensors)
        other_sensors(s).name = strrep(other_sensors(s).name, '-', '_');
        out(i).sensors.(other_sensors(s).name) = mksqlite(db, sprintf(['SELECT value FROM ctd '...
                             'LEFT JOIN other_sensors '...
                             'ON other_sensors.ctd_id = ctd.id and sensor_id = %d '...
                             'WHERE ctd.profile_id = %d '], s, results(i).id));
                       
    end
%     for s = 1:length(other_sensors)
%         sql = [sql, sprintf(' LEFT JOIN other_sensors as %s ON %s.ctd')];
%     end
%     sql = [sql, sprintf(' FROM ctd WHERE ctd.profile_id=%d ORDER BY pressure', results(i).id')];
%     samples = mksqlite(db, sql);
end
disp(sprintf('Runtime: %f seconds', (now-startTime)*24*60*60));
mksqlite(db, 'close');



function state = notDefault(field, parameters)
if any(strcmp(parameters.UsingDefaults, field))
    state = false;
else
    state = true;
end
