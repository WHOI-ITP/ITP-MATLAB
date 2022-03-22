clc
clear


path = 'J:/ITP Data/itp_final_2022_03_11.db';
DEPTH_RANGE = [0, 150];

profiles = load_itp(...
    path,...
    'system', 10,...
    'pressure', [0, 200]...
);

figure('Color', 'white')
ax = axes;
hold(ax, 'on')

for i = 1:length(profiles)
    plot(profiles(i).potential_temperature(0), profiles(i).depth, 'b.')
end
axis ij;
ylim(DEPTH_RANGE);

xlabel('Potential Temperature (°C)')
ylabel('Depth (m)')
