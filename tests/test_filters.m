function tests = test_filters
clc
tests = functiontests(localfunctions);
end


function test_abstract_class(testCase)
testCase.verifyError(@()DummyClass([1,2]).value(), 'ITP:notImplemented')
end


function test_wrong_n_inputs(testCase)
testCase.verifyError(@()LatitudeFilter([1,2,3]), 'ITP:valueError')
testCase.verifyError(@()LongitudeFilter([1,2,3]), 'ITP:valueError')
testCase.verifyError(@()DateTimeFilter([1,2,3]), 'ITP:valueError')
testCase.verifyError(@()PressureFilter([1,2,3]), 'ITP:valueError')
end


function test_empty_argument(testCase)
testCase.verifyError(@()LatitudeFilter([]), 'ITP:valueError')
testCase.verifyError(@()LongitudeFilter([]), 'ITP:valueError')
testCase.verifyError(@()DateTimeFilter([]), 'ITP:valueError')
testCase.verifyError(@()PressureFilter([]), 'ITP:valueError')
end


function test_not_numeric(testCase)
testCase.verifyError(@()DateTimeFilter('asdf'), 'ITP:valueError')
testCase.verifyError(@()LatitudeFilter('asdf'), 'ITP:valueError')
testCase.verifyError(@()LongitudeFilter('asdf'), 'ITP:valueError')
testCase.verifyError(@()MonthFilter('asdf'), 'ITP:valueError')
testCase.verifyError(@()PressureFilter('asdf'), 'ITP:valueError')
testCase.verifyError(@()SystemFilter('asdf'), 'ITP:valueError')
end


function test_system_filter_one_arg(testCase)
sql = SystemFilter(1).value();
testCase.verifyEqual(sql, '(system_number IN (1))')
end


function test_system_filter_two_args(testCase)
sql = SystemFilter([1,2]).value();
testCase.verifyEqual(sql, '(system_number IN (1,2))')
end


function test_latitude_filter_bad_range(testCase)
testCase.verifyError(@()LatitudeFilter([-91, 45]), 'ITP:valueError')
testCase.verifyError(@()LatitudeFilter([45, 91]), 'ITP:valueError')
end


function test_latitude_filter_wrong_order(testCase)
testCase.verifyError(@()LatitudeFilter([85, 75]), 'ITP:valueError')
end


function test_latitude_filter(testCase)
sql = LatitudeFilter([75.1, 85]).value();
testCase.verifyEqual(sql, '(latitude >= 75.1000 AND latitude <= 85.0000)')
end


function test_longitude_filter_bad_range(testCase)
testCase.verifyError(@()LongitudeFilter([-181, 45]), 'ITP:valueError')
testCase.verifyError(@()LongitudeFilter([45, 181]), 'ITP:valueError')
end


function test_longitude_filter_and_or(testCase)
sql = LongitudeFilter([1, 2]).value();
testCase.verifyEqual(sql, '(longitude >= 1.0000 AND longitude <= 2.0000)')

sql = LongitudeFilter([2, 1]).value();
testCase.verifyEqual(sql, '(longitude >= 2.0000 OR longitude <= 1.0000)')

sql = LongitudeFilter([1, 1]).value();
testCase.verifyEqual(sql, '(longitude >= 1.0000 AND longitude <= 1.0000)')
end


function test_date_time_filter_start_after_end(testCase)
time_range = [datenum(2020,1,1), datenum(1970,1,1)];
testCase.verifyError(@()DateTimeFilter(time_range), 'ITP:valueError')
end


function test_date_time_filter(testCase)
time_range = [datenum(1970,1,1), datenum(1971,5,1,1,2,33)];
sql = DateTimeFilter(time_range).value();
testCase.verifyEqual(sql, ...
    '(date_time BETWEEN "1970-01-01T00:00:00" AND "1971-05-01T01:02:33")')
end


function test_pressure_filter_top_lt_bottom(testCase)
testCase.verifyError(@()PressureFilter([2,1]), 'ITP:valueError')
end


function test_pressure_filter(testCase)
sql = PressureFilter([1,2]).value();
testCase.verifyEqual(sql, ...
    'AND (pressure >= 10000.0000 AND pressure <= 20000.0000)')
end


function test_extra_variable_filter(testCase)
args = {'dissolved_oxygen', 'par'};
sql = ExtraVariableFilter(args).value();
expected = ['(profiles.id IN ' ...
    '(SELECT profile_id FROM profile_extra_variables INNER JOIN ' ...
    'variable_names ON profile_extra_variables.variable_id ' ...
    '== variable_names.id WHERE variable_names.name IN ' ...
    '("dissolved_oxygen","par")))'];
testCase.verifyEqual(sql, expected)
end


function test_month_filter_decimal_month(testCase)
testCase.verifyError(@()MonthFilter([1, 2, 3.3]), 'ITP:valueError')
end


function test_month_filter_not_in_range(testCase)
testCase.verifyError(@()MonthFilter([1, 2, 13]), 'ITP:valueError')
end


function test_month_filter(testCase)
sql = MonthFilter([1, 11, 12]).value();
testCase.verifyEqual(sql, ...
    '(strftime("%m", date_time) IN ("01","11","12"))')
end


function test_direction_filter_not_string(testCase)
testCase.verifyError(@()DirectionFilter(999), 'ITP:valueError');
end


function test_direction_filter_incorrect_arg(testCase)
testCase.verifyError(@()DirectionFilter('sideways'), 'ITP:valueError');
end


function test_direction_filter(testCase)
sql = DirectionFilter('up').value();
testCase.verifyEqual(sql, '(direction = "up")')
end
