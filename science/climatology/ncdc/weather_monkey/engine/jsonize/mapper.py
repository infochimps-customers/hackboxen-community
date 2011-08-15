#!/usr/bin/env python

# Voronoi diagram
# FB - 201008087
import sys
import time, datetime

import math
from operator import itemgetter
import json

linecnt=0
sys.stderr.write("Mapper started!\n")

currenttime=time.time()

def putdata(data, title, station_property_dic):
  if data != "":
    title=title.split(">")

    if len(title)==1:
      station_property_dic[ title[0] ]=float(data)
    else:
      try:
        station_property_dic[ title[0] ][ title[1] ]=float(data)
      except:
        station_property_dic[ title[0] ]={}
        station_property_dic[ title[0] ][ title[1] ]=float(data)



for line in sys.stdin:
  linecnt+=1
  if linecnt%10000==0:
    
    sys.stderr.write("%d line processed.. Time elapsed: %f\n" % (linecnt, time.time()-currenttime))

  tz=sys.argv[1]
  #  break
  line=line.strip()
  data=line.split("\t")

  group=data[0].replace("(", "")
  group=group.replace(")", "")
  group=group.split(",")

  stations=data[1]
  stations=stations.replace("{","")
  stations=stations.replace("}","")
  stations=stations.replace(",(","")
  stations=stations.replace("(","")
  stations=stations.split(")")
  i=0
  for station in stations:
    stations[i]=station.split(",")
    i+=1



  #print group
  output="weather_observation:"+group[0]+"\tevent\t"

  cur_date="%4d%02d%02d" % ( int(group[1]), int(group[2]), int(group[3]) ) 
  cur_date_iso="%4d-%02d-%02d" % ( int(group[1]), int(group[2]), int(group[3]) ) 
  output+=cur_date+"\t"

  grid_dic={}

  grid_dic["type"]="FeatureCollection"
  grid_dic["id"]=group[0]
  grid_dic["features"]=[]



  for station in stations:

    if len(station)<=1:
      continue
    #print station[:4]
    station_data=station[2:]
    #print station_data

    duplicateFlag=False
    station_id=cur_date+"-"+station[1]
    for feat in grid_dic["features"]:
      if feat["id"]==station_id:
        duplicateFlag=True
        break

    if duplicateFlag: continue

    station_dic={}
    station_dic["type"]="Feature"
    station_dic["id"]=station_id

    station_dic["geometry"]={}
    station_dic["geometry"]["type"]="Point"

    lng=(int(station[2])/1000.0)
    lat=(int(station[3])/1000.0)

    station_dic["geometry"]["coordinates"]=[lng, lat]

    station_dic["properties"]={}

    
    station_property_dic={}
    
    station_property_dic["_type"]="science_climatology.weather_observation"
    station_property_dic["_domain_id"]=station_id
    station_property_dic["time_beg"]=cur_date_iso
    station_property_dic["weather_station_id"]=station[1]
    
  
    i=0
    condition_titles=["fog", "rain", "snow", "hail", "thunder", "tornado"]
    condition_list=[]
    for cond in station_data[-6:]:
      if float(cond)>0.5:
        condition_list.append(condition_titles[i])
      i+=1
    
    #if condition_list!=[]:
    station_property_dic["conditions"]=condition_list

    station_property_dic["station_id"]=station[1]




    putdata(station_data[5], "precipitation>average_value", station_property_dic)
    putdata(station_data[6], "snow_depth>average_value", station_property_dic)
    putdata(station_data[7], "air_temperature>average_value", station_property_dic)
    #putdata(station_data[8], "air_temperature>num_observations", station_property_dic)
    putdata(station_data[9], "air_temperature>maximum_value", station_property_dic)
    putdata(station_data[10], "air_temperature>minimum_value", station_property_dic)
    putdata(station_data[11], "dew_point>average_value", station_property_dic)
    #putdata(station_data[12], "dew_point>num_observations", station_property_dic)
    putdata(station_data[13], "sea_level_pressure>average_value", station_property_dic)
    #putdata(station_data[14], "sea_level_pressure>num_observations", station_property_dic)
    putdata(station_data[15], "station_pressure>average_value", station_property_dic)
    #putdata(station_data[16], "station_pressure>num_observations", station_property_dic)
    putdata(station_data[17], "visibility>average_value", station_property_dic)
    #putdata(station_data[18], "visibility>num_observations", station_property_dic)
    putdata(station_data[19], "wind_speed>average_value", station_property_dic)
    #putdata(station_data[20], "wind_speed>num_observations", station_property_dic)
    putdata(station_data[21], "wind_speed>maximum_value", station_property_dic)
    putdata(station_data[22], "wind_speed_gust>maximum_value", station_property_dic)

    
    station_dic["properties"]=station_property_dic.copy()
    grid_dic["features"].append(station_dic)
    
    #print station_property_dic

  output+=json.dumps(grid_dic, sort_keys=True)
    
  
  print output
  #print json.dumps(grid_dic, sort_keys=True, indent=4)
  #break

 
#hadoop jar engine/hadoop/hadoop-streaming-0.20.2-cdh3u0.jar -file engine/jsonize/mapper.py -mapper "engine/jsonize/mapper.py 6" -input data/hb/science/climatology/ncdc/fixd_zl6/data/output_full/ -output data/hb/science/climatology/ncdc/fixd_zl6/data/json


