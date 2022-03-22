function tests = test_profile
clc
tests = functiontests(localfunctions);
end


% gsw validations were done manually using MATLAB TEOS-10 toolbox


function p = dummy_profile()
p = Profile();
p.serial_time = datenum(1970, 1, 1);
p.latitude = 80;
p.longitude = 0;
p.pressure = [0, 1, 2, 3, 4, 5];
p.salinity = [20, 24, 28, 32, 36, 40];
p.temperature = [0, 1, 2, 3, 4, 5];
end


function test_p(testCase)
p = dummy_profile();
expected = datetime(1970, 1, 1);
testCase.verifyEqual(p.datetime, expected)
end


function test_absolute_salinity(testCase)
p = dummy_profile();
expected = [20.0956, 24.1147, 28.1338, 32.1529, 36.1721, 40.1912];
testCase.verifyEqual(p.absolute_salinity, expected, 'AbsTol', 0.0001)
end


function test_height(testCase)
p = dummy_profile();
expected = [0, -0.9894, -1.9788, -2.9682, -3.9576, -4.9470];
testCase.verifyEqual(p.height, expected, 'AbsTol', 0.0001)
end


function test_depth(testCase)
p = dummy_profile();
expected = [0, 0.9894, 1.9788, 2.9682, 3.9576, 4.9470];
testCase.verifyEqual(p.depth, expected, 'AbsTol', 0.0001)
end


function test_conservative_temp(testCase)
p = dummy_profile();
expected = [0.0399, 1.0500, 2.0435, 3.0214, 3.9842, 4.9327];
testCase.verifyEqual(p.conservative_temperature, ...
    expected, 'AbsTol', 0.0001)
end


function test_density(testCase)
p = dummy_profile();
expected = [1016.0, 1019.2, 1022.4, 1025.5, 1028.6, 1031.7];
testCase.verifyEqual(p.potential_density, expected, 'AbsTol', 0.1)
end


function test_potential_temperature(testCase)
p = dummy_profile();
expected = [0, 1.0000, 1.9999, 2.9998, 3.9997, 4.9996];
testCase.verifyEqual(p.potential_temperature, expected, 'AbsTol', 0.001)
end
