clc
clear


path = '../itp_final_2021_01_20.db';
dateRange = [datenum(2006, 1, 1), datenum(2008, 1, 1)];

profiles = load_itp(path,... 
                    'latitude', [70, 80],... 
                    'longitude', [-180, -130],... 
                    'date_time', dateRange,...
                    'pressure', [400, 402],...
                    'max_results', 10000);

temp_400 = zeros(length(profiles), 1);
for i = 1:length(profiles)
    temp_400(i) = profiles(i).temperature(1);
end

longitude = [profiles.longitude];
latitude = [profiles.latitude];

figure('Color', 'white')
worldmap([70, 90], [-180, 180]);
geoshow('landareas.shp', 'FaceColor', [0.5 0.7 0.5])
scatterm([profiles.latitude], [profiles.longitude], 15, temp_400, 'filled');
h = colorbar;
ylabel(h, 'In Situ Temperature (C)')
caxis([0.5, 1])
