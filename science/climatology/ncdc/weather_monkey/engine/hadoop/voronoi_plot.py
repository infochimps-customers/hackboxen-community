#! /usr/local/bin/python

print "Setting up"

from pylab import *
#import matplotlib
from shapely.geometry import Polygon
from shapely.ops import polygonize

import globalmaptiles

WorldRanges={}
WorldRanges["AUSTIN"]=[30800, -98500, 29535, -97031]
WorldRanges["TX"]=[36500, -106000, 25000, -93000]
WorldRanges["US"]=[55000, -130000, 23000, -60000]
WorldRanges["GUS"]=[60000, -140000, 22000, -50000]
WorldRanges["KR"]=[45000, 120000, 32000, 135000]
WorldRanges["W"]=[90000, -180000, -90000, 180000]

World="W"
WorldRange=WorldRanges[World]

ClosestZoomLevel=7

output=""

def plot_voronoi(voronoi_lattice):
  for station, data in voronoi_lattice.items():

    x=[]
    y=[]
    polygon_data=data["obj_polygon"]
    #print polygon_data
    for point in list(polygon_data.exterior.coords):
      x.append(point[0])
      y.append(point[1])
    
    #if station == 8 :
    #plot(x,y)
    fill(x,y, alpha=0.3)

    #scatter(data["coordinate"][0], data["coordinate"][1])

def quadGrid(grid_range):
  #print grid_range
  bix=(grid_range[0]+grid_range[2])/2
  biy=(grid_range[1]+grid_range[3])/2
  
  grid0=[grid_range[0], grid_range[1], bix, biy]
  grid1=[grid_range[0], biy, bix, grid_range[3]]
  grid2=[bix, grid_range[1], grid_range[2], biy]
  grid3=[bix, biy, grid_range[2], grid_range[3]]

  return (grid0, grid1, grid2, grid3)

def polygonize_grid(grid_range):
  x0=grid_range[1]*1000
  y0=grid_range[0]*1000
  x1=grid_range[3]*1000
  y1=grid_range[2]*1000

  polygon=( (x0, y0), (x0, y1), (x1, y1), (x1, y0), (x0, y0))
  return polygon

def get_quadkeystr(quadkey):
  for i in range(ClosestZoomLevel-len(quadkey)):
    quadkey+="X"
  return quadkey
#Zoom in!!
def GridMap(quadkey="", ploygons_to_lookat=None):

  mercator = globalmaptiles.GlobalMercator()
    

  for quadkeyadd in range(4):
    curQuadKey=quadkey+str(quadkeyadd)

    tx, ty, zl=mercator.QuadTree2TMS(curQuadKey)
    grid_latlon=mercator.TileLatLonBounds(tx, ty, zl)    
    #print grid_latlon

    polygon=polygonize_grid(grid_latlon) 

    #print polygon

    obj_polygon=Polygon(polygon)

    inter_cnt=0
    
    Grid_Weather_Stations=[]    

    ploygons_to_lookat_new=[]
    for pobj in ploygons_to_lookat:
      #print pobj, obj_polygon
      if pobj[0].intersection(obj_polygon):
        inter_cnt+=1
        ploygons_to_lookat_new.append(pobj)


    #print inter_cnt
    if inter_cnt> 10 and zl<ClosestZoomLevel:
      GridMap(curQuadKey, ploygons_to_lookat_new)

      continue

    quadkeystr=get_quadkeystr(curQuadKey)

    global output
    global curDate

    
    for pobj in  ploygons_to_lookat_new:
      #print output+=quadkeystr, 
      print curDate[:4]+"\t"+curDate[4:]+"\t"+quadkeystr+"\t"+pobj[1][0]+"\t"+str(pobj[2][0])+"\t"+str(pobj[2][1])+"\t"+"\t".join(pobj[1][1:])



def GridVoronoi(CurrentDate,voronoi_lattice, zl):
  #print "Mapping the Grids"
  
  global ClosestZoomLevel
  ClosestZoomLevel=zl

  global curDate
  curDate=CurrentDate

  ploygons_to_lookat_new=[]
  for station, data in voronoi_lattice.items():
    ploygons_to_lookat_new.append((data["obj_polygon"], data["info"], data["coordinate"] ))


  GridMap("", ploygons_to_lookat_new)


