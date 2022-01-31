## BigQuery SQL Data Cleaning

###  Added
* `day_of_week` column created from `started_at`, with integers 1-7 corresponding to Sunday-Saturday

###  Changed
* 2020.10 and 2020.11 tables use integer values for `start_station_id` and `end_station_id` columns, changed to string values to match the other tables

###  Fixed
* removed rows where `started_at` occurred after `ended_at`



**End product:** bikeshare_v4.csv



## Changes in RStudio

### bikeshare_v5
* Added: `ride_length` column created from `ended_at` - `started_at` columns

### bikeshare_v6
* Changed: replaced NA values of start and end station names and IDs with "undocked"

### bikeshare_v7
* Changed: `rideable_type` instances of "docked bike" to "classic_bike"

### bikeshare_v8
* Changed: converted `ride_length` to a `lubridate` duration object for easier reading

### bikeshare_v9
* Added: created `ride_length_min`, ride_length expressed in minutes as a numeric datatype
* Changed: `ride_length` to `ride_length_dur` for clarity

### bikeshare_v10
* Fixed: removed outlier rows with a `ride_length_dur` longer than 1440 minutes(1 day) or shorter than 30 seconds

### bikeshare_v11
* Added: `area` column with "Hyde_Park", "Evanston", "Z1", "Z2", and "noncluster" categories by setting boundaries of  `start_lat` and `start_lng` values, based on [Divvy's Zone classification](https://account.divvybikes.com/map) and interpreted below

   Z1:  start_lat > 41.822978 & start_lat < 42.0219536 & start_lng > -87.690118 & start_lng < -87.593127
   
   Z2_nocollege:   start_lat > 41.643837 & start_lat < 42.0219536 & start_lng > -87.836541 & start_lng < -87.524491 & isFALSE(start_lat > 41.77 & start_lat < 41.82 & start_lng > -87.61 & start_lng < -87.56)
   
   Hyde Park: start_lat > 41.77 & start_lat < 41.82 & start_lng > -87.61 & start_lng < -87.56
   
   Evanston:  start_lat > 42.0219536 & start_lat < 42.07 & start_lng > -87.69 & start_lng < -87.65
                  


### bikeshare_v12
* Removed: examined "noncluster" rows and found them to be 44 rows outside of Zone 2 boundaries

### bikeshare_v13
* Fixed: removed rows less than 1 minute, in keeping with Divvy's policy on their data

### bikeshare_v14
* Added: calculated the Manhattan distance between start and end lat-lng data columns, stored in miles as `ride_ml`
* Added: calculated average speed of ride  from `ride_length_min` and `ride_ml`, stored in mph as `speed_mph`

### bikeshare_v15
* Changed: `area` column parameters altered to distinguish Evanston from Northwestern University

 * Z1: start_lat > 41.822978 & start_lat < 42.0219536 & start_lng > -87.690118 & start_lng < -87.593127
   
 * Hyde_Park: start_lat > 41.77 & start_lat < 41.82 & start_lng > -87.61 & start_lng < -87.56
   
 * Z2_nocollege: start_lat > 41.643837 & start_lat < 42.0219536 & start_lng > -87.836541 & start_lng < -87.524491
   
 * E_NWU: start_lat > 42.044047 & start_lng > -87.684714 & start_lat < 42.07 & start_lng < -87.65
   
 * E_nocollege: start_lat > 42.0219536
                 
    The E_nocollege includes a section that technically is part of Z1, a 2x4 block section just south of Cavalry Catholic Cemetery

### bikeshare_v16
* Changed: `E_nocollege` > `Ev_nocollege`
           `E_NWU` > `Ev_NW_College`
* Fixed: readjusted Hyde_Park boundaries to specific streets
  * `Hyde_Park`    - E. 63rd St. in the South - (41.780428 lat)
                   - S. Martin Luther King Dr. in the West - (-87.615707 lng)
                   - E. Hyde Park Blvd in the North - (41.802297 lat)
                   - S. Stony Is Ave. in the East - (-87.586710 lng)
                 
  * `Ev_NW_College`- Bordered by Lake St. in the South - (42.044047 lat)
                   - Maple Ave. in the West - (-87.684714 lng)
               
 * `Ev_nocollege`  - Bordered by W. Howard St. in the South - (42.0219536 lat)
                   - excluding the `Ev_NW_College` area
                   
 * `Z1`            - Bordered by W. Pershing Rd in the South - (41.822978 lat)
                   - N Western Ave. in the West - (-87.690118 lng)
                   - W Howard St. in the North - (42.0219536 lat)
                   - these borders omit a small chunk of the north of `Z1`, 
                      assigning it instead to `Ev_nocollege`
                      
 * `Z2_nocollege`  - Out to Indiana state line in the East - (-87.524491 lng)
                   - W Howard St. in the North - (42.0219536 lat)
                   - excludes `Z1` and `Hyde_Park`

### bikeshare_v17
* Removed: `ride_length_dur` was no longer needed 
