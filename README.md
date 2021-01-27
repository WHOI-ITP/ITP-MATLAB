# ITP-MATLAB
The Ice Tethered Profiler (ITP) is an autonomous instrument that vertically profiles the water column under sea ice. The ITP collects measurements of conductivity, temperature, and depth. Data are automatically transmitted back via satellite.  [Learn More](http://www.whoi.edu/itp "Learn More")

## Motivation
To date, 119 ITP systems have been deployed, and more than 130000 water profiles have been collected. As these data continue to accumulate, and the number of users working with the data increases, the need has become apparent for a set of tools to access, search for, and manipulate ITP data.

## Features
  - Easily and rapidly search all available ITP profiles
  - Search profiles based on
    - latitude range
    - longitude range
    - date range
    - pressure range
    - system number
  - Profiles are returned as a MATLAB structured array

## Usage
#### load\_itp(db\_path, [arguments])
`load_itp` is the primary function used to retrieve ITP data from the database. It accepts a variety of filtering arguments. **Please pay attention to the order in which the bounds are specified for the various arguments.**
##### Arguments
Argument | Description
:--- | :---
db_path | A path to the database containing ITP profiles.
latitude | A two element vector specifying the Southern and Northern bounding parallels. Acceptable range is [-90 to 90]
longitude | A two element vector specifying the Western and Eastern bounding meridians.. Acceptable meridian range is [-180, 180].
date_time | A two element vector specifying the start and end times of the search. Times must be specified in **MATLAB serial time format**. The search is inclusive of the start date and exclusive of the end date.
pressure | A two element vector specifying the lowest and highest pressure bounds for returned profiles (in dbar). Note that pressure range only specifies pressure bounds. It does not ensure that a profile will have pressure values up to the bounds.
system | A vector of ITP system numbers to filter for.
max\_results | The maximum number of results the `load_itp` function will return without throwing an error. The default value is 10000.


#### Example Usage
Once you have downloaded the ITP-MATLAB package and added it to your MATLAB path, you need to download the ITP database. See the bottom of this page for instructions on doing both. 

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
The function returns the request profiles and outputs:
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


## Installation (non-git method)
  1. Download the latest `ITP-MATLAB` package https://github.com/WHOI-ITP/ITP-MATLAB/archive/master.zip Save it to a temporary location.
  2. Unzip the file. Rename the unzipped folder to `ITP-MATLAB`.
  3. Move the `ITP-MATLAB` folder to your preferred location. e.g. `C:\ITP-MATLAB`
  4. Download the itp database, from here: https://www.dropbox.com/sh/5u68j8h5eiamk1x/AABZTJd3Hx2y-GAsoBKyZo01a?dl=0 Unzip it to your desired location (it's probably easiest to just put it in the ITP-MATLAB folder), and take note of its path (you'll need to specify it when you query the database).
  5. In MATLAB, type `pathtool` in the command window. 
  6. Click the `Add Folder...` button.
  7. Browse to the ITP-MATLAB folder from step 3 and add the `itp_matlab` and `mksqlite-1.5` sub-folders to the path.
  8. Click `Save` and close the path window.
