clc
clear


path = 'J:/ITP Data/itp_final_2021_11_09.db';
profiles = load_itp(path, 'system', 100,'extra_variables', {'dissolved_oxygen'});

figure('Color', 'white')
plot(profiles(1).other_variables.dissolved_oxygen, ...
    profiles(1).depth)
axis ij;

xlabel('Dissolved Oxygen')
ylabel('Depth (m)')
