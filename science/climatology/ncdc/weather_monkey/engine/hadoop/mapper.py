#!/usr/bin/env python

# Voronoi diagram
# FB - 201008087
import sys
import time, datetime

import math
from operator import itemgetter

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

    quadKey = mercator.QuadTree(tx, ty, tz)
  except:
    sys.stderr.write("Error in converting "+str(Coord)+"\n")
    return None

  return quadKey


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
for line in sys.stdin:

  #  break
  line=line.strip()
  line=line.replace("\"","")
  data=line.split(",")

  #print data

  if data[2]=="STATION NAME":
    CurrentData=1
    continue

  StationID=data[0]+"-"+data[1]

  #For World
  WorldRange=[90000, -180000, -90000, 180000]

  #Station History Data

  if CurrentData==1:
    #continue
    i+=1
    if i%1000==0:
      sys.stderr.write(str(i)+"\n")
    #if i>200:
    #  continue


    try:
      Coord=( int(data[7]), int(data[8]) )
    except:
      continue

    if checkInRange(WorldRange,Coord)==False:
      continue

    time_format = "%Y%m"
    try:
      begindate=time.strptime(data[10][:6],time_format)
      #print begindate
      #begindate.tm_mday=1
      enddate=time.strptime(data[11][:6],time_format)
      #enddate.tm_mday=1
    except:
      continue

    #print "Begin:",begindate.tm_year, begindate.tm_mon
    #print "End:",enddate.tm_year, enddate.tm_mon

    #sys.stderr.write ( "Zoom Level:", sys.argv[1])
    GridID=GetGridID(Coord, sys.argv[1])
    if (GridID==None):
      continue

    for year in range(begindate.tm_year, enddate.tm_year+1):
      for month in range(1,13):
        Curdate=time.strptime(str(year)+("%02d" % month),"%Y%m")
        #print Curdate
        if Curdate<begindate or Curdate>enddate:
          continue
        DateCode=str(Curdate.tm_year)+("%02d" % Curdate.tm_mon)

        print StationID+"-"+DateCode+"\t"+GridID+","+str(Coord[0])+","+str(Coord[1])+","+data[2]+","+data[3]+","+data[4]

sys.stderr.write("Mapper done!\n")

