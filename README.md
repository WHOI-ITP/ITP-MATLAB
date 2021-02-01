# ITP-MATLAB
The Ice Tethered Profiler (ITP) is an autonomous instrument that vertically profiles the water column under sea ice. The ITP collects measurements of conductivity, temperature, and depth. Data are automatically transmitted back via satellite.  [Learn More](http://www.whoi.edu/itp "Learn More")

## Motivation
To date, 119 ITP systems have been deployed, and more than 130000 water profiles have been collected. As these data continue to accumulate, and the number of users working with the data increases, the need has become apparent for a set of tools to search for and access ITP data. 

## Features
  - Easily and rapidly search all ITP profiles
  - Search for profiles based on
    - latitude range
    - longitude range
    - date range
    - pressure range
    - system number
  - Profiles matching the search criteria will be returned as an array of `Profile` objects. Profile objects have built in methods for calculating many common derived values such as depth and potential temperature. 

## Usage
#### load\_itp(db\_path, [arguments])
`load_itp` is the primary function used to retrieve ITP data from the database. It accepts a variety of filtering arguments. **Please pay attention to the order in which the bounds are specified for the various arguments.** `load_itp` returns a vector of `Profile` objects that match the search criteria.
##### Search Arguments
Argument | Description
:--- | :---
db_path | A path to the database containing ITP profiles.
latitude | A two element vector specifying the Southern and Northern bounding parallels. Acceptable range is [-90 to 90]
longitude | A two element vector specifying the Western and Eastern bounding meridians.  Acceptable meridian range is [-180, 180].
date_time | A two element vector specifying the start and end times of the search. Times must be specified in **MATLAB serial time format**. The search is inclusive of the start date and exclusive of the end date.
pressure | A two element vector specifying the lowest and highest pressure bounds for returned profiles (in dbar). Note that pressure range only specifies pressure bounds. It does not guarantee that a profile will have the full range of pressure values.
system | A vector of ITP system numbers to filter for.
max\_results | The maximum number of results the `load_itp` function will return without throwing an error. The default value is 10000.

#### Profile
The `load_itp` function returns an array of `Profile` objects.
##### Properties
Each `Profile` object represents a single profile with the following properties:

Property | Description 
:---|:---
serial_time | the MATLAB serial time in the UTC time when the profile began  
latitude  |the latitude where the profile started 
longitude | the longitude where the profile started 
system_number | an integer representing the ITP number 
profile_number | an integer representing the profile number 
pressure | a vector of pressure values (dbar) (1xN) 
temperature | a vector of in-situ temperature values (°C) (1xN) 
salinity | a vector of practical salinity values (1xN) 

##### Methods

`Profile` objects have the following methods:

**datetime**()  
Returns the start time of the profile in MATLAB `datetime` format 

**height**()  
Calculates height from sea pressure (+ up).

**depth**()  
Calculates depth from sea pressure; simply negative height (+ down).

**potential\_temperature**(*[p_ref]*)  
Calculates potential temperature at a specified reference pressure, `p_ref`. If p_ref is omitted, a default value of 0 is used.  

**potential\_density**(*[p_ref]*)  
Calculates potential density at a specified reference pressure, `p_ref`. If p_ref is omitted, a default value of 0 is used.  

**conservative\_temperature**()  
Calculates Conservative Temperature  

**absolute\_salinity**()  
Calculates Absolute Salinity  

## Examples
Once you have downloaded the ITP-MATLAB package and added it to your MATLAB path, you need to download the ITP database. See the bottom of this page for instructions on doing both. The .m files for these examples are in the <a href='https://github.com/WHOI-ITP/ITP-MATLAB/tree/master/examples'>examples folder</a>.

### Example - The Basics
The following example demonstrates how to retrieve all profiles from 2010 in the region bounded by 70 and 80 degrees North, and 170 to 140 degrees West. 

First specify the path to the database file you downloaded. This will be used in the `load_itp` function call.
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
The function returns the requested profiles as a vector of `Profile` objects:
```
1546 profiles returned in 2.68 seconds
```
You can investigate a `Profile` object to see its [properties](#properties). 
```
>> profiles(1)
Profile with properties:
     system_number: 32
    profile_number: 179
          latitude: 79.6348
         longitude: -143.3919
       serial_time: 7.3414e+05
          pressure: [1×700 double]
       temperature: [1×700 double]
          salinity: [1×700 double]
```
The properties can be accessed using dot notation

```
>> profiles(1).latitude
ans =
   79.6348
```

`Profile` [methods](#methods) can be called to calculate derived values:

```
>> profiles(1).depth()
ans =
  Columns 1 through 11
   29.8787   30.6701   31.5604   32.6486   33.6379   34.6272   35.6164   36.6057   37.5950   38.5842   39.5734
  Columns 12 through 22
   40.5627   41.5519   42.5411   43.5304   44.6185   45.5088   46.4980   47.4872   48.4764   49.4656   50.4548
  ...
  Columns 694 through 700
   714.1130  715.1976  716.1836  717.0709  718.0569  719.1415  719.6345
```
Square braces can be used to extract scalar values from the vector of profiles. For example if you want all the latitude values:
```
>> [profiles.latitude]
ans =
  Columns 1 through 11
   79.6348   79.6262   79.6067   79.6148   79.6393   79.6474   79.6719   79.6670   79.6522   79.6604   79.6849
  Columns 12 through 22
   79.6924   79.7147   79.7108   79.6991   79.6797   79.6213   79.6047   79.5545   79.5564   79.5620   79.5780
  ...
  Columns 1541 through 1546
   75.3289   75.1791   74.9671   74.7733   74.6489   74.5291
```

### Example - Plot a Potential Temperature vs Depth profile
Plot the first profile from ITP 10
```
path = '../itp_final_2021_01_20.db';
profiles = load_itp(path, 'system', 10);

figure('Color', 'white')
plot(profiles(1).potential_temperature(0), profiles(1).depth)
axis ij;

xlabel('Potential Temperature (°C)')
ylabel('Depth (m)')
```

<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/profile.PNG' height='400'/>


### Example - Over-plot Potential Temperature vs Depth for all profile
Plot all data points between 0 and 150 meters for ITP 10
```
path = '../itp_final_2021_01_20.db';
DEPTH_RANGE = [0, 150];

profiles = load_itp(...
    path,...
    'system', 10,...
    'pressure', [0, 1]...
);

figure('Color', 'white')
ax = axes;
hold(ax, 'on')

for i = 1:length(profiles)
    plot(profiles(i).potential_temperature(0), profiles(i).depth, 'b.')
end
axis ij;
ylim(DEPTH_RANGE);
```
<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/overplot.PNG' height='400'/>

### Example - Show profile locations on a map (requires MATLAB mapping toolbox)
Show the locations of all profiles in the Beaufort Gyre region from 2019
```
path = '../itp_final_2021_01_20.db';
dateRange = [datenum(2019, 1, 1), datenum(2020, 1, 1)];

profiles = load_itp(path,... 
                    'latitude', [70, 80],... 
                    'longitude', [-170, -140],... 
                    'date_time', dateRange);

figure('Color', 'white')
worldmap([70, 90], [-180, 180]);
geoshow('landareas.shp', 'FaceColor', [0.5 0.7 0.5])
scatterm([profiles.latitude], [profiles.longitude], 3, 'filled');
```
<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/scatter.PNG' height='400'/>

### Example - Plot a temperature section for the top 300 meters of ITP 1
```
PRESSURE_RANGE = [0, 300];

path = '../itp_final_2021_01_20.db';
profiles = load_itp(path, 'system', 1, 'pressure', PRESSURE_RANGE);

% extract latitude and longitude values
latitude = [profiles.latitude]';
longitude = [profiles.longitude]';

% calculate distance between profiles in km 
% the distance function requires mapping toolbox
profile_spacing = distance(...
    [latitude(1:end-1), longitude(1:end-1)],...
    [latitude(2:end), longitude(2:end)],...
    referenceEllipsoid('GRS80')...
);
profile_spacing = profile_spacing / 1000;

% calculate cumulative drift distance
cumulative_distance = [0; cumsum(profile_spacing)];

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
    ptemp = profiles(i).potential_temperature(0);  % reference of 0 dbar
    temp_vec = [temp_vec, ptemp(I)];
    dist_vec = [dist_vec, repmat(cumulative_distance(i), 1, sum(I))];
end

% get rid of any NaN values in ptemp
notNan = ~isnan(temp_vec);
depth_vec = depth_vec(notNan); 
temp_vec = temp_vec(notNan); 
dist_vec = dist_vec(notNan); 

tempInterpolant = scatteredInterpolant(dist_vec', depth_vec', temp_vec');
temp_grid = tempInterpolant(dist_grid, pres_grid);

% Plot the data
figure('Color', 'white')
contourf(dist_grid, pres_grid, temp_grid, 6, 'LineColor', 'none')
axis ij
h = colorbar;
xlabel('Drift Distance (km)');
ylabel('Pressure (mbar)');
ylabel(h, 'Potential Temperature (C)')
```
<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/itp1_section.PNG' height='400'/>

### Example - Show a map with temperature at 400m

```
path = '../itp_final_2021_01_20.db';
dateRange = [datenum(2006, 1, 1), datenum(2008, 1, 1)];

profiles = load_itp(path,... 
                    'latitude', [70, 80],... 
                    'longitude', [-180, -130],... 
                    'date_time', dateRange,...
                    'pressure', [400, 402],...
                    'max_results', 10000);

temp_400 = zeros(length(profiles), 1);
for i = 1:length(profiles)
    % calculate potential temperature with a reference pressure of 0
    ptemp = profiles(i).potential_temperature(0);
    temp_400(i) = ptemp(1);
end

longitude = [profiles.longitude];
latitude = [profiles.latitude];

figure('Color', 'white')
worldmap([70, 90], [-180, 180]);
geoshow('landareas.shp', 'FaceColor', [0.5 0.7 0.5])
scatterm([profiles.latitude], [profiles.longitude], 15, temp_400, 'filled');
h = colorbar;
ylabel(h, 'Potential Temperature (C)')
caxis([0.3, 1])
```

<img src='https://github.com/WHOI-ITP/ITP-MATLAB/raw/master/resources/temperature_400m.PNG' height='400'/>

## Installation
#### Requirements
ITP-MATLAB depends on an open-source package called **Mksqlite**. The **TEOS-10 Gibbs Seawater Toolbox** is required for calculating derived values (e.g. density, potential temperature, etc), but it is not strictly required to query the database. However without it, you will be limited to accessing a profile's pressure, in-situ temperature, and practical salinity.

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