#!/usr/bin/env python

# Voronoi diagram
# FB - 201008087
import sys
import time, datetime

import math
from operator import itemgetter
import json

class GlobalGeodetic(object):

	def __init__(self, tileSize = 256):
		self.tileSize = tileSize

	def LatLonToPixels(self, lat, lon, zoom):
		"Converts lat/lon to pixel coordinates in given zoom of the EPSG:4326 pyramid"

		res = 180 / 256.0 / 2**zoom
		px = (180 + lat) / res
		py = (90 + lon) / res
		return px, py

	def PixelsToTile(self, px, py):
		"Returns coordinates of the tile covering region in pixel coordinates"

		tx = int( math.ceil( px / float(self.tileSize) ) - 1 )
		ty = int( math.ceil( py / float(self.tileSize) ) - 1 )
		return tx, ty

	def Resolution(self, zoom ):
		"Resolution (arc/pixel) for given zoom level (measured at Equator)"

		return 180 / 256.0 / 2**zoom
		#return 180 / float( 1 << (8+zoom) )

	def TileBounds(tx, ty, zoom):
		"Returns bounds of the given tile"
		res = 180 / 256.0 / 2**zoom
		return (
			tx*256*res - 180,
			ty*256*res - 90,
			(tx+1)*256*res - 180,
			(ty+1)*256*res - 90
		)

class GlobalMercator(object):
	def __init__(self, tileSize=256):
		"Initialize the TMS Global Mercator pyramid"
		self.tileSize = tileSize
		self.initialResolution = 2 * math.pi * 6378137 / self.tileSize
		# 156543.03392804062 for tileSize 256 pixels
		self.originShift = 2 * math.pi * 6378137 / 2.0
		# 20037508.342789244

	def LatLonToMeters(self, lat, lon ):
		"Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"

		mx = lon * self.originShift / 180.0
		my = math.log( math.tan((90 + lat) * math.pi / 360.0 )) / (math.pi / 180.0)

		my = my * self.originShift / 180.0
		return mx, my

	def MetersToLatLon(self, mx, my ):
		"Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum"

		lon = (mx / self.originShift) * 180.0
		lat = (my / self.originShift) * 180.0

		lat = 180 / math.pi * (2 * math.atan( math.exp( lat * math.pi / 180.0)) - math.pi / 2.0)
		return lat, lon

	def PixelsToMeters(self, px, py, zoom):
		"Converts pixel coordinates in given zoom level of pyramid to EPSG:900913"

		res = self.Resolution( zoom )
		mx = px * res - self.originShift
		my = py * res - self.originShift
		return mx, my

	def MetersToPixels(self, mx, my, zoom):
		"Converts EPSG:900913 to pyramid pixel coordinates in given zoom level"

		res = self.Resolution( zoom )
		px = (mx + self.originShift) / res
		py = (my + self.originShift) / res
		return px, py

	def PixelsToTile(self, px, py):
		"Returns a tile covering region in given pixel coordinates"

		tx = int( math.ceil( px / float(self.tileSize) ) - 1 )
		ty = int( math.ceil( py / float(self.tileSize) ) - 1 )
		return tx, ty

	def PixelsToRaster(self, px, py, zoom):
		"Move the origin of pixel coordinates to top-left corner"

		mapSize = self.tileSize << zoom
		return px, mapSize - py

	def MetersToTile(self, mx, my, zoom):
		"Returns tile for given mercator coordinates"

		px, py = self.MetersToPixels( mx, my, zoom)
		return self.PixelsToTile( px, py)

	def TileBounds(self, tx, ty, zoom):
		"Returns bounds of the given tile in EPSG:900913 coordinates"

		minx, miny = self.PixelsToMeters( tx*self.tileSize, ty*self.tileSize, zoom )
		maxx, maxy = self.PixelsToMeters( (tx+1)*self.tileSize, (ty+1)*self.tileSize, zoom )
		return ( minx, miny, maxx, maxy )

	def TileLatLonBounds(self, tx, ty, zoom ):
		"Returns bounds of the given tile in latutude/longitude using WGS84 datum"

		bounds = self.TileBounds( tx, ty, zoom)
		minLat, minLon = self.MetersToLatLon(bounds[0], bounds[1])
		maxLat, maxLon = self.MetersToLatLon(bounds[2], bounds[3])

		return ( minLat, minLon, maxLat, maxLon )

	def Resolution(self, zoom ):
		"Resolution (meters/pixel) for given zoom level (measured at Equator)"

		# return (2 * math.pi * 6378137) / (self.tileSize * 2**zoom)
		return self.initialResolution / (2**zoom)

	def ZoomForPixelSize(self, pixelSize ):
		"Maximal scaledown zoom of the pyramid closest to the pixelSize."

		for i in range(30):
			if pixelSize > self.Resolution(i):
				return i-1 if i!=0 else 0 # We don't want to scale up

	def GoogleTile(self, tx, ty, zoom):
		"Converts TMS tile coordinates to Google Tile coordinates"

		# coordinate origin is moved from bottom-left to top-left corner of the extent
		return tx, (2**zoom - 1) - ty

	def RevGoogleTile(self, gx, gy, zoom):
		"Converts TMS tile coordinates to Google Tile coordinates"

		# coordinate origin is moved from bottom-left to top-left corner of the extent
		return gx, (2**zoom - 1) - gy

	def QuadTree(self, tx, ty, zoom ):
		"Converts TMS tile coordinates to Microsoft QuadTree"

		quadKey = ""
		ty = (2**zoom - 1) - ty
		for i in range(zoom, 0, -1):
			digit = 0
			mask = 1 << (i-1)
			if (tx & mask) != 0:
				digit += 1
			if (ty & mask) != 0:
				digit += 2
			quadKey += str(digit)

		return quadKey



def GetGridID(Coord, tz):
  tz=int(tz)
  lat=Coord[0]/1000.0
  lon=Coord[1]/1000.0

  try:
    mercator = GlobalMercator()
    mx, my = mercator.LatLonToMeters( lat, lon )
    tx, ty = mercator.MetersToTile( mx, my, tz )

    gx, gy = mercator.quadKey(tx, ty, tz)
  except:
    sys.stderr.write("Error in converting "+str(Coord)+"\n")
    return None

  return ("%05d" % gx)+("%05d" % gy)

def GridID2Quadkey(gx, gy, tz):
  tz=int(tz)
  gx=int(gx)
  gy=int(gy)

  try:
    mercator = GlobalMercator()
    tx, ty = mercator.RevGoogleTile(gx, gy, tz)
    quadkey = mercator.QuadTree(tx, ty, tz)
  except:
    sys.stderr.write("Error in converting "+str(Coord)+"\n")
    return None

  return quadkey


def checkInRange(WorldRange,Coord):
  lat=Coord[0]
  lon=Coord[1]
  if lon>=WorldRange[1] and lon<=WorldRange[3]:
    if lat<=WorldRange[0] and lat>=WorldRange[2]:
      return True
  return False


def putdata(data, title, json_dic):
  if data != "":
    title=title.split(">")

    if len(title)==1:
      json_dic[ title[0] ]=float(data)
    else:
      try:
        json_dic[ title[0] ][ title[1] ]=float(data)
      except:
        json_dic[ title[0] ]={}
        json_dic[ title[0] ][ title[1] ]=float(data)



linecnt=0
sys.stderr.write("Mapper started!\n")

currenttime=time.time()

for line in sys.stdin:
  linecnt+=1
  if linecnt%10000==0:
    
    sys.stderr.write("%d line processed.. Time elapsed: %f\n" % (linecnt, time.time()-currenttime))

  tz=sys.argv[1]
  #  break
  line=line.strip()
  data=line.split("\t")

  #print data
  output="weather_observation:"+GridID2Quadkey(data[0], data[1], tz)+"\tevent\t"

  
  i=0
  condition_titles=["fog", "rain", "snow", "hail", "thunder", "tornado"]
  condition_list=[]
  for cond in data[-6:]:
    if float(cond)>=0.5:
      condition_list.append(condition_titles[i])
    i+=1

  output+=("%4d%02d%02d" % ( int(data[2]), int(data[3]), int(data[4]) ) )+"\t"

  json_dic={}
  
  if condition_list!=[]:
    json_dic["conditions"]=condition_list

  putdata(data[5], "precipitation", json_dic)
  putdata(data[6], "snow_depth", json_dic)
  putdata(data[7], "temperature>average", json_dic)
  putdata(data[8], "temperature>num_observations", json_dic)
  putdata(data[9], "temperature>max", json_dic)
  putdata(data[10], "temperature>min", json_dic)
  putdata(data[11], "dew_point>average", json_dic)
  putdata(data[12], "dew_point>num_observations", json_dic)
  putdata(data[13], "sea_level_pressure>average", json_dic)
  putdata(data[14], "sea_level_pressure>num_observations", json_dic)
  putdata(data[15], "station_pressure>average", json_dic)
  putdata(data[16], "station_pressure>num_observations", json_dic)
  putdata(data[17], "visibility>average", json_dic)
  putdata(data[18], "visibility>num_observations", json_dic)
  putdata(data[19], "wind_speed>average", json_dic)
  putdata(data[20], "wind_speed>num_observations", json_dic)
  putdata(data[21], "wind_speed_maximum_sustained", json_dic)
  putdata(data[22], "wind_speed_maximum_gust", json_dic)

  #print json_dic
  output+=json.dumps(json_dic, sort_keys=True)
  
  print output


 
#hadoop jar engine/hadoop/hadoop-streaming-0.20.2-cdh3u0.jar -file engine/jsonize/mapper.py -mapper "engine/jsonize/mapper.py 6" -input data/hb/science/climatology/ncdc/fixd_zl6/data/output_full/ -output data/hb/science/climatology/ncdc/fixd_zl6/data/json


