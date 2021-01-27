clc
clear

PRESSURE_RANGE = [0, 300];

path = '../itp_final_2021_01_20.db';
profiles = load_itp(path, 'system', 1, 'pressure', PRESSURE_RANGE);

% extract latitude and longitude values
latitude = [profiles.latitude]';
longitude = [profiles.longitude]';

% calculate distance between stations in km 
% the distance function requires mapping toolbox
station_spacing = distance(...
    [latitude(1:end-1), longitude(1:end-1)],...
    [latitude(2:end), longitude(2:end)],...
    referenceEllipsoid('GRS80')...
);
station_spacing = station_spacing / 1000;

% calculate cumulative drift distance
cumulative_distance = [0; cumsum(station_spacing)];

% make grids from distance and pressure
[dist_grid, pres_grid] = meshgrid(cumulative_distance,...
                                   PRESSURE_RANGE(1):PRESSURE_RANGE(2));

% Use scatteredInterpolant to create a temperature grid for use
% with contourf
depth_vec = []; dist_vec = []; temp_vec = [];
for i = 1:length(profiles)
    I = profiles(i).pressure >= PRESSURE_RANGE(1) & ...
        profiles(i).pressure < PRESSURE_RANGE(2);
    depth_vec = [depth_vec, profiles(i).pressure(I)];
    temp_vec = [temp_vec, profiles(i).temperature(I)];
    dist_vec = [dist_vec, repmat(cumulative_distance(i), 1, sum(I))];
end
tempInterpolant = scatteredInterpolant(dist_vec', depth_vec', temp_vec');
temp_grid = tempInterpolant(dist_grid, pres_grid);

% Plot the data
figure('Color', 'white')
contourf(dist_grid, pres_grid, temp_grid, 6, 'LineColor', 'none')
axis ij
h = colorbar;
xlabel('Drift Distance (km)');
ylabel('Pressure (mbar)');
ylabel(h, 'In Situ Temperature (C)')
