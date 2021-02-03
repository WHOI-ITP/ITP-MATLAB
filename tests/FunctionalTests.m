% These tests ensure the expected values are being returned from 
% the database.

classdef FunctionalTests < matlab.unittest.TestCase
    properties
        profiles = NaN;
    end
    
    methods(TestClassSetup)
        function loadDatabase(testCase)
            path = 'itp_final_2021_02_02.db';
            testCase.profiles = load_itp(path, 'system', 10);
        end
    end
    
    methods(Test)
        function testNumberOfProfiles(testCase)
            testCase.verifyEqual(length(testCase.profiles), 515);
        end
        
        function testPresTempSalt(testCase)
            % verify that pressure, temperature and salinity values
            % returned from the database match a raw file
            data = importdata('data/itp10grd0001.dat', ' ', 3);
            expected = data.data;
            % use profile 1 as a reference
            profile = testCase.profiles(1);
            testCase.verifyEqual(...
                profile.pressure, expected(:,1)', 'AbsTol', 0.0001);
            testCase.verifyEqual(...
                profile.temperature, expected(:,2)', 'AbsTol', 0.0001);
            testCase.verifyEqual(...
                profile.salinity, expected(:,3)', 'AbsTol', 0.0001);
        end
        
        function testSystemAndProfileNumber(testCase)
            testCase.verifyEqual(...
                testCase.profiles(end).system_number, 10);
            testCase.verifyEqual(...
                testCase.profiles(end).profile_number, 535);
        end
        
        function testLatLon(testCase)
            % from itp10grd0535.dat header
            testCase.verifyEqual(...
                testCase.profiles(end).latitude, 83.5618,...
                'AbsTol', 0.0001);
            testCase.verifyEqual(...
                testCase.profiles(end).longitude, -110.7519,...
                'AbsTol', 0.0001);
        end
        
        function testSerialTime(testCase)
            % from itp10grd00001.dat header
            expected = datenum(2007, 1, 1) - 1 + 253.75003;
            testCase.verifyEqual(...
                testCase.profiles(1).serial_time, expected,...
                'AbsTol', 0.0001);
        end
        
    end
end