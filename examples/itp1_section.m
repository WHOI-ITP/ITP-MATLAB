clc
clear

PRESSURE_RANGE = [0, 300];

path = '../itp_final_2021_01_20.db';
profiles = load_itp(path, 'system', 1, 'pressure', PRESSURE_RANGE);

% extract latitude and longitude values
latitude = [profiles.latitude]';
longitude = [profiles.longitude]';

% calculate distance between profiles in km 
% the distance function requires mapping toolbox
profile_spacing = distance(...
    [latitude(1:end-1), longitude(1:end-1)],...
    [latitude(2:end), longitude(2:end)],...
    referenceEllipsoid('GRS80')...
);
profile_spacing = profile_spacing / 1000;

% calculate cumulative drift distance
cumulative_distance = [0; cumsum(profile_spacing)];

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
    ptemp = profiles(i).potential_temperature(0);  % reference of 0 dbar
    temp_vec = [temp_vec, ptemp(I)];
    dist_vec = [dist_vec, repmat(cumulative_distance(i), 1, sum(I))];
end

% get rid of any NaN values in ptemp
notNan = ~isnan(temp_vec);
depth_vec = depth_vec(notNan); 
temp_vec = temp_vec(notNan); 
dist_vec = dist_vec(notNan); 

tempInterpolant = scatteredInterpolant(dist_vec', depth_vec', temp_vec');
temp_grid = tempInterpolant(dist_grid, pres_grid);

% Plot the data
figure('Color', 'white')
contourf(dist_grid, pres_grid, temp_grid, 6, 'LineColor', 'none')
axis ij
h = colorbar;
xlabel('Drift Distance (km)');
ylabel('Pressure (mbar)');
ylabel(h, 'Potential Temperature (C)')
