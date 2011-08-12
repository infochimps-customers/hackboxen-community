weather_data = LOAD '$WEATHER' AS (
       sid:chararray, year:chararray, month:chararray, day:chararray, 
       precipitation:float, snow_depth:float, tmp_average:float, 
       tmp_observations:float, tmp_max:float, tmp_min:float, dew_point_average:float, 
       dew_point_observations:float, sea_level_pressure_average:float, sea_level_pressure_observations:float, 
       station_pressure_average:float, station_pressure_observations:float, visibility_average:float, 
       visibility_observations:float, wind_speed_average:float, wind_speed_observations:float, 
       wind_speed_maximum_sustained:float, wind_speed_maximum_gust:float, fog:float, rain:float, 
       snow:float, hail:float, thunder:float, tornado:float
     );

station_data = LOAD '$STATIONS' AS (year:chararray, month:chararray, quadkey:chararray, sid:chararray, lat:int, lng:int);

cogrouped = COGROUP station_data BY (sid, year, month), weather_data BY (sid, year, month);

flattened= FOREACH cogrouped GENERATE FLATTEN(station_data.quadkey) AS (quadkey),
  FLATTEN(station_data.(sid, lat, lng)) AS (sid, lat, lng),
  FLATTEN(weather_data.(year, month, day, precipitation, snow_depth, 
    tmp_average, tmp_observations, 
    tmp_max, tmp_min, dew_point_average, dew_point_observations, 
    sea_level_pressure_average, sea_level_pressure_observations, 
    station_pressure_average, station_pressure_observations, 
    visibility_average, visibility_observations, wind_speed_average, 
    wind_speed_observations, wind_speed_maximum_sustained, wind_speed_maximum_gust,
    fog, rain, snow, hail, thunder, tornado
  )) AS (year, month, day, precipitation, snow_depth, tmp_average, tmp_observations,
    tmp_max, tmp_min, dew_point_average, dew_point_observations,
    sea_level_pressure_average, sea_level_pressure_observations,
    station_pressure_average, station_pressure_observations,
    visibility_average, visibility_observations, wind_speed_average,
    wind_speed_observations, wind_speed_maximum_sustained, wind_speed_maximum_gust,
    fog, rain, snow, hail, thunder, tornado);

grouped_by_day = GROUP flattened BY (quadkey, year, month, day);

STORE grouped_by_day INTO '$OUTPUT';

/*
c = FOREACH grouped_by_day GENERATE FLATTEN(group) as (quadkey, year, month, day),
    AVG(flattened.precipitation), AVG(flattened.snow_depth), AVG(flattened.tmp_average), 
    AVG(flattened.tmp_observations), AVG(flattened.tmp_max), AVG(flattened.tmp_min), 
    AVG(flattened.dew_point_average), AVG(flattened.dew_point_observations), 
    AVG(flattened.sea_level_pressure_average), AVG(flattened.sea_level_pressure_observations), 
    AVG(flattened.station_pressure_average), AVG(flattened.station_pressure_observations), 
    AVG(flattened.visibility_average), AVG(flattened.visibility_observations), 
    AVG(flattened.wind_speed_average), AVG(flattened.wind_speed_observations), 
    AVG(flattened.wind_speed_maximum_sustained), AVG(flattened.wind_speed_maximum_gust),
    AVG(flattened.fog), AVG(flattened.rain), AVG(flattened.snow),
    AVG(flattened.hail), AVG(flattened.thunder), AVG(flattened.tornado);

STORE c INTO '$OUTPUT';

*/
