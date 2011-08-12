#!/usr/bin/env python


import sys
import time, datetime

sys.stderr.write("Reducer started!\n")
CurGridID=""
station_data=[]
#GridIDs=[]
for line in sys.stdin:
  data=line.strip().split("\t")
  
  if len(data)<2:
    continue

  key=data[0].split("-")
  value=data[1].split(",")


  station_data=value[1:]
  GridID=value[0]
  print key[2]+"-"+GridID+"\t"+key[0]+"-"+key[1]+","+",".join(station_data)

