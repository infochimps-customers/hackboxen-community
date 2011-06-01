require 'rubygems'
require 'rgeo'
require 'rgeo/shapefile'
require 'rgeo/geo_json'
require 'sqlite3'


module SqliteShapeDB

  def self.create_from_shapefile(shapefile_path, sqlite3_path)
    SqliteShapeDB.open_db(sqlite3_path)
    SqliteShapeDB.create_shape_table
    SqliteShapeDB.process_shapes(shapefile_path)
    @db.close
  end

  def self.process_shapes(shapefile_path)
    RGeo::Shapefile::Reader.open(shapefile_path) { |shapes|
      num_shapes = shapes.num_records
      n = 1
      shapes.each { |record|
        print "\r  #{n} of #{num_shapes} shapes"; STDOUT.flush
        attrs = record.attributes
        geoid = attrs["GEOID10"]
        name = attrs["NAME10"]
        geometry = RGeo::GeoJSON.encode(record.geometry).to_json
        SqliteShapeDB.insert_shape(geoid, name, geometry)
        n += 1
      }
      puts
    }
  end

  def self.open_db(filename)
    @db = SQLite3::Database.new(filename)
    @db.synchronous = 0
    @db.execute("pragma locking_mode = exclusive")
  end

  def self.create_shape_table
    @db.execute <<-EOF
      create table if not exists shapes (geoid text unique, name text, geojson blob)
    EOF
    @db.execute("create index if not exists geoididx on shapes (geoid)")
  end

  def self.insert_shape(geoid, name, geometry)
    @db.execute("insert or replace into shapes values (?,?,?)",
      geoid, name, geometry)
  end

  def self.find_shape(geoid)
    ret = @db.execute("select name,geojson from shapes where geoid=?", geoid)
    ret[0] if ret
  end

end
