# ITP-MATLAB
The Ice Tethered Profiler (ITP) is an autonomous instrument that vertically profiles the water column under sea ice. The ITP collects measurements of conductivity, temperature, and depth. Data are automatically transmitted back via satellite.  [Learn More](http://www.whoi.edu/itp "Learn More")

## Motivation
To date, 119 ITP systems have been deployed, and more than 130000 water profiles have been collected. As these data continue to accumulate, and the number of users working with the data increases, the need has become apparent for a set of tools to access, search for, and manipulate ITP data.

## Features
  - Easily and rapidly read from all available ITP profiles
  - Search profiles based on
    - latitude range
    - longitude range
    - date range
    - pressure range
    - system number
  - Profiles are returned as a MATLAB structured array

## Usage
#### load_itp(db_path, [parameters])
`load_itp` is the primary function used to retrieve ITP data from the database. It accepts a variety of filtering parameters. **Please pay attention to the order in which the bounds are specified for the various parameters.**
##### Parameters
  * **db_path**
    A path to the database containing ITP profiles.
  * **latitude**
    A two element vector specifying the Southern and Northern bounding parallels.
  * **longitude**
    A two element vector specifying the Western and Eastern bounding meridians.. Acceptable meridian range is [-180, 180].
  * **date_time**
    A two element vector specifying the start and end times of the search. Times must be specified in MATLAB *serial time format*.
  * **pressure**
    A two element vector specifying the lowest and highest pressure bounds for returned profiles (in dbar).
  * **system**
    A vector of ITP system numbers to filter for.
  * **max_results**
    The maximum number of results the `load_itp` function will return without throwing an error. *

*By default `load_itp` is limited to returning 10000 profiles in order to avoid protracted wait times and/or memory limitations in the event of an overly broad search.

#### Example Usage
Return all profiles bounded by the parallels 70 and 80 degrees, the meridians -170 and -140 degrees, during the year 2010.
```
>> path = 'c:/path/to/database.db';
>> startTime = datenum(2010, 1, 1);
>> endTime = datetime(2010, 12, 31)
>> profiles = load_itp(path, 'latitude', [70, 80], 'longitude', [-170, -140], 'date_time', [startTime, endTime]);
1539 profiles returned in 2.68 seconds
```
Return all profiles from the second half of 2008 clipping the pressure at 100 dbar.
```
>> profiles = load_itp(path, 'date_time', [datenum(2008,7,1), datenum(2008,12,31)], 'pressure', [0, 100]);
3885 profiles returned in 3.69 seconds
```
Return all profiles from ITPs 1, 2, 3.
```
>> profiles = load_itp(path, 'system', [1, 2, 3]);
>> profiles = load_itp(path, 'system', [1:3]); % would also work
3797 profiles returned in 7.49 seconds
```

## Installation (non-git method)
  1. Download the latest `ITP-MATLAB` package https://github.com/WHOI-ITP/ITP-MATLAB/archive/master.zip Save it to a temporary location.
  2. Unzip the file. Rename the unzipped folder to `ITP-MATLAB`.
  3. Move the `ITP-MATLAB` folder to your preferred location. e.g. `C:\ITP-MATLAB`
  4. Download the itp database, temporarily stored here: https://drive.google.com/open?id=1IaUmIbZ2WEg1dqWqW7_TLMxUkTIVV_fh Unzip it to your desired location, and take note of its path.
  5. In MATLAB, type `pathtool` in the command window. 
  6. Click the `Add Folder...` button.
  7. Browse to the ITP-MATLAB folder from step 3 and add the `itp_matlab` and `mksqlite-1.5` sub-folders to the path (both were contained in the zip file. You have to add each to the MATLAB path separately)
  8. Click `Save` and close the path window.
