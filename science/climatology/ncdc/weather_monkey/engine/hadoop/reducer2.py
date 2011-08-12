#!/usr/bin/env python

import sys
import time
import voronoi_gen
import voronoi_plot


if len(sys.argv)!=2:
  print "python reducer2.py <zoomlevel>"
  raise

temp_data=[]

CurrentDate=""
PointsMap={}

def output_station(currentKey, includedKeys, PointsMap,finalLength, CurrentDate):

  for i in range(finalLength-len(currentKey)):
    currentKey+="X"
  for quadkey in includedKeys:
    for std in PointsMap[quadkey]:
      print CurrentDate[:4]+"\t"+CurrentDate[4:]+"\t"+currentKey+"\t"+"\t".join(std)

  
def GetGridItems(root, CurrentDate, PointKeys, PointsMap, tz, finalLength, upperLevelKeys=[]):
  for quad in range (0,4):
    currentKey=root+str(quad)
    tempQuadkeys=[]
    observationCount=0

    for quadkey in PointKeys:      
      if quadkey.startswith(currentKey):
        #print quadkey
        tempQuadkeys.append(quadkey)
        observationCount+=len(PointsMap[quadkey])

    if observationCount>3 and tz<finalLength:
      GetGridItems(currentKey, CurrentDate, PointKeys, PointsMap, tz+1, finalLength, tempQuadkeys)
      #print currentKey, len(tempQuadkeys), observationCount
    else:
      
      if len(tempQuadkeys)==0:
        output_station(currentKey, upperLevelKeys, PointsMap, finalLength, CurrentDate)
      else:
        output_station(currentKey, tempQuadkeys, PointsMap, finalLength, CurrentDate)


def PopulateGrids(CurrentDate, PointsMap):

  PointKeys=PointsMap.keys()

  PointKeys.sort()
  
  finalLength=len(PointKeys[0])

  GetGridItems("", CurrentDate, PointKeys, PointsMap, 1, finalLength)


def VoronoiGrids(CurrentDate, PointsMap):

  zl=int(sys.argv[1])

  #print zl,"----------------"
  vl=voronoi_gen.GenerateVoronoi(CurrentDate, PointsMap)      
  grid_station_data=voronoi_plot.GridVoronoi(CurrentDate, vl, zl)


# Do Stuff Here
t = time.clock()
sys.stderr.write("Reducer 2 started!\n")

for line in sys.stdin:

  data=line.strip().split("\t")
  if len(data)<2:
    continue

  Date=data[0]


  value=data[1].split(",")
  GID=value[0]
  value=value[1:]

  if Date!=CurrentDate and len(CurrentDate)==6:

    if len( PointsMap.keys() )>0:
      sys.stderr.write(CurrentDate+":")
      VoronoiGrids(CurrentDate, PointsMap)
      sys.stderr.write(str(time.clock()-t)+"\n")
      t = time.clock()
    PointsMap={}

  try:
    if not value in PointsMap[GID]:
      PointsMap[GID].append(value)
  except:
    PointsMap[GID]=[value]

  CurrentDate=Date

#Don't forget the last month!
sys.stderr.write(CurrentDate+":")
VoronoiGrids(CurrentDate, PointsMap)
sys.stderr.write(str(time.clock()-t)+"\n")

