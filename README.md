# ITP-MATLAB
The Ice Tethered Profiler (ITP) is an autonomous instrument that vertically profiles the water column under sea ice. The ITP collects measurements of conductivity, temperature, and depth. Data are automatically transmitted back via satellite.  [Learn More](http://www.whoi.edu/itp "Learn More")

## Motivation
To date, 119 ITP systems have been deployed, and more than 130000 water profiles have been collected. As these data continue to accumulate, and the number of users working with the data increases, the need has become apparent for a set of tools to search for and access ITP data.

## Features
  - Easily and rapidly search all available ITP profiles
  - Search profiles based on
    - latitude range
    - longitude range
    - date range
    - pressure range
    - system number
  - Profiles matching the search criteria will be returned as an array of `Profile` objects. Profile objects have built in methods for calculating many common derived values such as potential temperature and depth.

## Usage
#### load\_itp(db\_path, [arguments])
`load_itp` is the primary function used to retrieve ITP data from the database. It accepts a variety of filtering arguments. **Please pay attention to the order in which the bounds are specified for the various arguments.** `load_itp` returns a vector of `Profile` objects.
##### Search Arguments
Argument | Description
:--- | :---
db_path | A path to the database containing ITP profiles.
latitude | A two element vector specifying the Southern and Northern bounding parallels. Acceptable range is [-90 to 90]
longitude | A two element vector specifying the Western and Eastern bounding meridians.. Acceptable meridian range is [-180, 180].
date_time | A two element vector specifying the start and end times of the search. Times must be specified in **MATLAB serial time format**. The search is inclusive of the start date and exclusive of the end date.
pressure | A two element vector specifying the lowest and highest pressure bounds for returned profiles (in dbar). Note that pressure range only specifies pressure bounds. It does not ensure that a profile will have pressure values up to the bounds.
system | A vector of ITP system numbers to filter for.
max\_results | The maximum number of results the `load_itp` function will return without throwing an error. The default value is 10000.

#### Profile
A `profile` object has the following methods:

**height**()  
Calculates height from sea pressure (+ up).

**depth**()  
Calculates depth from sea pressure; simply negative height (+ down).

**potential\_temperature**(*pressure_reference*)  
Calculates potential temperature from in-situ temperature. You must specify a reference pressure.

**density**()  
Calculates in-situ density

**conservative\_temperature**()  
Calculates Conservative Temperature from in-situ temperature

**absolute\_salinity**()  
Calculates Absolute Salinity from Practical Salinity

## Examples
Once you have downloaded the ITP-MATLAB package and added it to your MATLAB path, you need to download the ITP database. See the bottom of this page for instructions on doing both. The .m files for these examples are in the <a href='https://github.com/WHOI-ITP/ITP-MATLAB/tree/master/examples'>examples folder</a>.

### Example - The basics


Search the database based on a geographical area and time range, then make a scatter plot of the station locations
The following example demonstrates how to retrieve all profiles from 2010 in the region bounded by 70 and 80 degrees North, and 170 to 140 degrees West. 

First specify the path to the database file you downloaded.
```
path = 'c:/path/to/database.db';
```
Then create a vector with the date range (dates specified as MATLAB serial time). Remember the upper date range is exclusive so no profiles form Jan 1, 2011 will be returned.
```
dateRange = [datenum(2010, 1, 1), datenum(2011, 1, 1)];
```
Finally, call the load_itp function with the desired arguments. Note the order that the bounds are specified: Southern, Northern for latitude, and Western, Eastern for longitude. 
```
profiles = load_itp(path, 'latitude', [70, 80], 'longitude', [-170, -140], 'date_time', dateRange);
```
The function returns the requested profiles:
```
1539 profiles returned in 2.68 seconds
```
`profiles` can be investigated to see the available fields
```
>> profiles
profiles = 
  1539×1 struct array with fields:
    latitude
    longitude
    serialTime
    pressure
    temperature
    cruise
    station
    salt
```
Using the above data, scatter plot the locations of all the stations on a map (requires MATLAB mapping toolbox)

```
worldmap([70, 90], [-180, 180]);
geoshow('landareas.shp', 'FaceColor', [0.5 0.7 0.5])
scatterm([profiles.latitude], [profiles.longitude], 3, 'filled');
```
<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/scatter.PNG' height='400'/>

### Example - Plot a temperature section for the top 300 meters of ITP 1
```
PRESSURE_RANGE = [0, 300];

path = 'c:/path/to/database.db';
profiles = load_itp(path, 'system', 1, 'pressure', PRESSURE_RANGE);

% extract latitude and longitude values
latitude = [profiles.latitude]';
longitude = [profiles.longitude]';

% calculate distance between stations in km 
% the distance function requires mapping toolbox
station_spacing = distance(...
    [latitude(1:end-1), longitude(1:end-1)],...
    [latitude(2:end), longitude(2:end)],...
    referenceEllipsoid('GRS80')...
);
station_spacing = station_spacing / 1000;

% calculate cumulative drift distance
cumulative_distance = [0; cumsum(station_spacing)];

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
    temp_vec = [temp_vec, profiles(i).temperature(I)];
    dist_vec = [dist_vec, repmat(cumulative_distance(i), 1, sum(I))];
end
tempInterpolant = scatteredInterpolant(dist_vec', depth_vec', temp_vec');
temp_grid = tempInterpolant(dist_grid, pres_grid);

% Plot the data
figure('Color', 'white')
contourf(dist_grid, pres_grid, temp_grid, 6, 'LineColor', 'none')
axis ij
h = colorbar;
xlabel('Drift Distance (km)');
ylabel('Pressure (mbar)');
ylabel(h, 'In Situ Temperature (C)')
```
<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/itp1_section.PNG' height='400'/>

### Example - Show a map with temperature at 400m

```
path = 'c:/path/to/database.db';
dateRange = [datenum(2006, 1, 1), datenum(2008, 1, 1)];

profiles = load_itp(path,... 
                    'latitude', [70, 80],... 
                    'longitude', [-180, -130],... 
                    'date_time', dateRange,...
                    'pressure', [400, 402],...
                    'max_results', 10000);

temp_400 = zeros(length(profiles), 1);
for i = 1:length(profiles)
    temp_400(i) = profiles(i).temperature(1);
end

longitude = [profiles.longitude];
latitude = [profiles.latitude];

figure('Color', 'white')
worldmap([70, 90], [-180, 180]);
geoshow('landareas.shp', 'FaceColor', [0.5 0.7 0.5])
scatterm([profiles.latitude], [profiles.longitude], 15, temp_400, 'filled');
h = colorbar;
ylabel(h, 'In Situ Temperature (C)')
caxis([0.5, 1])
```

<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/temperature_400m.PNG' height='400'/>

## Installation
#### Requirements
ITP-MATLAB depends on a free, 3rd party open-source package called **Mksqlite**. The **TEOS-10 Gibbs Seawater Toolbox** is required for calculating derived values (e.g. density, potential temperature, etc), but it is not strictly required to query the database. However without it, you will be limited to accessing a profile's pressure, in-situ temperature, and practical salinity.

#### Windows users
  1. Download the <a href='https://github.com/WHOI-ITP/ITP-MATLAB/archive/master.zip'>latest ITP-MATLAB package</a>. 
  2. Unzip the file. Rename the unzipped folder to `ITP-MATLAB`.
  3. Download the <a href='https://www.dropbox.com/sh/5u68j8h5eiamk1x/AABZTJd3Hx2y-GAsoBKyZo01a?dl=0'>latest ITP database</a>. Unzip it to your desired location, and take note of its path. yyyy\_mm\_dd is the date the database was built.
  4. Download the <a href='http://www.teos-10.org/software.htm'>TEOS-10 Gibbs Seawater Toolbox</a>.
  5. In MATLAB, type `pathtool` in the command window. 
  6. Click the `Add Folder...` button.
  7. Browse to the ITP-MATLAB folder from step 2 and add the `itp_matlab` and `mksqlite-1.5` folders to the path.
  8. Click `Add with Subfolders...` and select the `gsw_matlab_v3_06_12` folder.
  9. Click `Save` and close the path window.
  
#### Mac Users
Installation steps are the same, but you must compile mksqlite from source. Find the latest release here: https://github.com/AndreasMartin72/mksqlite/tags Run buildit.m to compile to a MEX-DLL. Unfortunately I don't have a Mac so I'm unable to test this. Please open an issue if you have trouble and I will see if I can help.