clc
clear


path = 'J:/ITP Data/itp_final_2022_03_11.db';
profiles = load_itp(path, 'system', 10);

figure('Color', 'white')
plot(profiles(1).potential_temperature(0), profiles(1).depth)
axis ij;

xlabel('Potential Temperature (�C)')
ylabel('Depth (m)')
