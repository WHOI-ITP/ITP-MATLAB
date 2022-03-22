clc
clear

path = 'J:/ITP Data/itp_final_2022_03_11.db';
dateRange = [datenum(2019, 1, 1), datenum(2020, 1, 1)];

profiles = load_itp(path,... 
                    'latitude', [70, 80],... 
                    'longitude', [-170, -140],... 
                    'date_time', dateRange);

figure('Color', 'white')
worldmap([70, 90], [-180, 180]);
geoshow('landareas.shp', 'FaceColor', [0.5 0.7 0.5])
scatterm([profiles.latitude], [profiles.longitude], 3, 'filled');
