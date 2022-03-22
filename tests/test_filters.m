function tests = test_filters
clc
tests = functiontests(localfunctions);
end


function test_wrong_n_inputs(testCase)
testCase.verifyError(@()LatitudeFilter([1,2,3]), 'ITP:valueError')
testCase.verifyError(@()LongitudeFilter([1,2,3]), 'ITP:valueError')
testCase.verifyError(@()DateTimeFilter([1,2,3]), 'ITP:valueError')
testCase.verifyError(@()PressureFilter([1,2,3]), 'ITP:valueError')
end