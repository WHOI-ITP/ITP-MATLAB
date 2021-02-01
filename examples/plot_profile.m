clc
clear


path = '../itp_final_2021_01_20.db';

profiles = load_itp(path, 'system', 10);

figure('Color', 'white')
plot(profiles(1).potential_temperature(0), profiles(1).depth)
axis ij;


xlabel('Potential Temperature (°C)')
ylabel('Depth (m)')
