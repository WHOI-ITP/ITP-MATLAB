function tests = test_load_itp
clc
tests = functiontests(localfunctions);
end


function test_number_of_profiles(testCase)
results = load_itp('testdb.db', 'system', [1, 2]);
testCase.verifyEqual(length(results), 20);
end


function test_basic_query_validate_data(testCase)
% these values were verified by parsing itp1grd0001.dat by hand
results = load_itp('testdb.db', 'system', [1]);
testCase.verifyEqual( ...
    results(1).serial_time, datenum(2005,8,16,6,0,0))
testCase.verifyEqual(length(results), 10)
testCase.verifyEqual(results(1).system_number, 1)
testCase.verifyEqual(results(1).profile_number, 1)
testCase.verifyEqual( ...
    results(1).latitude, 78.8267, 'AbsTol', 0.0001)
testCase.verifyEqual( ...
    results(1).longitude, -150.1313, 'AbsTol', 0.0001)
testCase.verifyEqual( ...
    results(1).salinity, ...
    [28.9558; 28.9696; 29.0048; 29.1166; 29.3397; 29.5717; ...
    29.8253; 29.9834; 30.0896; 30.1587], 'AbsTol', 0.0001)
testCase.verifyEqual( ...
    results(1).temperature, ...
    [-1.4637; -1.4608; -1.4538; -1.4295; -1.3907; -1.3626; ...
    -1.3522; -1.3603; -1.3633; -1.3668], 'AbsTol', 0.0001)
testCase.verifyEqual( ...
    results(1).pressure, ...
    [9.7; 11.0; 12.0; 13.0; 14.0; 15.0; 16.1; ...
    17.1; 18.1; 19.1], 'AbsTol', 0.0001)
end


function test_query_unknown_argument(testCase)
testCase.verifyError(@()load_itp('testdb.db', 'purple', 'cow'), ...
    'MATLAB:InputParser:UnmatchedParameter');
end


function test_query_too_many_results(testCase)
testCase.verifyError( ...
    @()load_itp('testdb.db', 'system', [1], 'max_results', 5), ...
    'ITP:excessResults')
end


function test_validate_extra_variables(testCase)
% the test database has 10 profiles with DO from itp100
results = load_itp('testdb.db', 'extra_variables', {'dissolved_oxygen'});
testCase.verifyEqual(length(results), 10)
end


function test_validate_extra_fields_not_cell_array(testCase)
testCase.verifyError( ...
    @()load_itp('testdb.db', 'extra_variables', 'dissolved_oxygen'), ...
    'ITP:valueError')
end


function test_validate_extra_fields_unknown_variable(testCase)
testCase.verifyError( ...
    @()load_itp('testdb.db', 'extra_variables', ...
    {'dissolved_oxygen', 'chipmunk'}), ...
    'ITP:valueError')
end


function test_pressure_filter(testCase)
results = load_itp('testdb.db', 'pressure', [0, 100]);
testCase.verifyEqual(length(results), 58)
end


function test_latitude_filter(testCase)
results = load_itp('testdb.db', 'system', 1, 'latitude', [78.75, 90]);
testCase.verifyEqual(length(results), 5)
testCase.verifyEqual([results.profile_number], [1,2,3,4,5])
end


function test_longitude_filter(testCase)
results = load_itp('testdb.db', 'system', 1, 'longitude', [-150, 0]);
testCase.verifyEqual(length(results), 3)
testCase.verifyEqual([results.profile_number], [8,9,10])
results = load_itp('testdb.db', 'system', 1, 'longitude', [0, -150]);
testCase.verifyEqual(length(results), 7)
testCase.verifyEqual([results.profile_number], [1,2,3,4,5,6,7])
end


function test_time_filter(testCase)
time_range = [datenum(2005, 8, 17), datenum(2005, 9, 1)];
results = load_itp('testdb.db', 'system', 1, 'date_time', time_range);
testCase.verifyEqual(length(results), 7)
testCase.verifyTrue(all([results.serial_time] >= datenum(2005, 8, 17)))
testCase.verifyTrue(all([results.serial_time] < datenum(2005, 9, 1)))
end


function test_time_filter_no_results(testCase)
time_range = [datenum(2001, 8, 17), datenum(2001, 9, 1)];
results = load_itp('testdb.db', 'system', 1, 'date_time', time_range);
testCase.verifyEqual(length(results), 0)
end


function test_query_no_args(testCase)
results = load_itp('testdb.db');
testCase.verifyEqual(length(results), 60)
end
