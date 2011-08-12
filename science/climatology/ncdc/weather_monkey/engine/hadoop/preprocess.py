#!/usr/bin/env python

# Voronoi diagram
# FB - 201008087
import sys
import time, datetime

import math
from operator import itemgetter

from globalmaptiles import GlobalMercator


def GetGridID(Coord):
  lat=Coord[0]/1000
  lon=Coord[1]/1000

  tz=8

  mercator = GlobalMercator()
  mx, my = mercator.LatLonToMeters( Coord[0]/1000.0, Coord[1]/1000.0 )
  tx, ty = mercator.MetersToTile( mx, my, tz )

  gx, gy = mercator.GoogleTile(tx, ty, tz)
	#print "\tGoogle:", gx, gy

  #print tx, ty

  return ("%03d" % gx)+("%03d" % gy)

def checkInRange(WorldRange,Coord):
  lat=Coord[0]
  lon=Coord[1]
  if lon>=WorldRange[1] and lon<=WorldRange[3]:
    if lat<=WorldRange[0] and lat>=WorldRange[2]:
      return True
  return False

CurrentData=0
i=0
j=0
sys.stderr.write("Mapper started!\n")

PointMap={}


for line in sys.stdin:
  f=open("ish-history.csv")
  m_range={}
  m_range["max_lon"]=-9999999999
  m_range["max_lat"]=-9999999999
  m_range["min_lon"]=9999999999
  m_range["min_lat"]=9999999999

  #Put world range left top Latitude, Longitude to right bottom Latitude, Longitude
  #For US
  #WorldRange=[55000, -130000, 23000, -60000]

  #For Korea
  #WorldRange=[45000, 120000, 32000, 135000]

  #For World
  WorldRange=[90000, -180000, -90000, 180000]

  points=[]
  points_data={}
  i=0
  for line in f:
    i+=1
    #print i
    line=line.strip()
    line=line.replace("\"","")
    data=line.split(",")

    try:
      Coord=(int(data[7]), int(data[8]))
      if checkInRange(WorldRange, Coord)==False:
        continue

      time_format = "%Y%m%d"
      #print data
      begindate=time.strptime(data[10],time_format)
      enddate=time.strptime(data[11],time_format)

    except:
      sys.stderr.write( "Error in "+str(data)+"\n" )
      continue

    for year in range(begindate.tm_year, enddate.tm_year+1):
      for month in range(1,13):
        Curdate=time.strptime(str(year)+("%02d" % month),"%Y%m")
        #print Curdate
        if Curdate<begindate or Curdate>enddate:
          continue
        DateCode=str(Curdate.tm_year)+("%02d" % Curdate.tm_mon)
        #print DateCode

        if not DateCode in PointMap.keys():
          PointMap[DateCode]={}

        GridID=GetGridID(Coord)
        if not GridID in PointMap[DateCode].keys():
          PointMap[DateCode][GridID]=[]
        PointMap[DateCode][GridID].append(data[0]+"-"+data[1])

        print DateCode+"-"+GridID+"\t"+data[0]+"-"+data[1]+","+str(Coord[0])+","+str(Coord[1])+","+data[2]+","+data[3]+","+data[4]



#Get the points data
#PointMap=GetData()

#print PointMap

