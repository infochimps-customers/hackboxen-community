#!/usr/bin/env python

# Voronoi diagram
# FB - 201008087
import sys

sys.stderr.write("Mapper started!-----------------------------------\n")
i=0
for line in sys.stdin:
  i+=1
#  if i>2000:
#    continue
  #  break
  line=line.strip()
  #print line
  #line=line.replace("\"","")
  data=line.split("\t")
  key=data[0].split("-")
  print key[0]+"\t"+key[1]+","+data[1]

sys.stderr.write("Mapper done!-----------------------------------\n")

