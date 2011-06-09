require 'rubygems'
require 'rgeo'
require 'rgeo/shapefile'
require 'rgeo/geo_json'
require 'sqlite3'


module SqliteShapeDB

  def self.create_from_shapefile(shapefile_path, sqlite3_path)
    SqliteShapeDB.open_db_no_check(sqlite3_path)
    SqliteShapeDB.create_tables
    mt = File.mtime(shapefile_path).strftime("%Y-%m-%d %H:%M:%S")
    if SqliteShapeDB.check_time(shapefile_path, mt)
      SqliteShapeDB.process_shapes(shapefile_path)
      SqliteShapeDB.insert_timestamp(shapefile_path, mt)
    end
    @db.close
  end

  def self.open_db(filename)
    if !File.exists?(filename)
      raise "SQLite database not found: #{filename}"
    end
    SqliteShapeDB.open_db_no_check(filename)
  end

private

  def self.process_shapes(shapefile_path)
    # Need the .dup below because RGeo::Shapefile::Reader.open() is an evil
    # function that modified the string passed to it.
    RGeo::Shapefile::Reader.open(shapefile_path.dup) { |shapes|
      num_shapes = shapes.num_records
      n = 1
      shapes.each { |record|
        print "\r  #{n} of #{num_shapes} shapes"; STDOUT.flush
        attrs = record.attributes
        name = attrs["NAMELSAD10"]
        name = attrs["NAME10"] if !name || name.empty?
        geo_key = attrs["LSAD10"] + attrs["GEOID10"]
        begin
          geometry = RGeo::GeoJSON.encode(record.geometry).to_json
          SqliteShapeDB.insert_shape(geo_key, name, geometry)
        rescue => e
          puts "  ERROR: on '#{name}', key '#{geo_key}'"
          puts "  ERROR: #{e.class} - #{e.message}"
          e.backtrace.each { |b| puts "    #{b}" }
        end
        n += 1
      }
      puts
    }
  end

  def self.open_db_no_check(filename)
    @db = SQLite3::Database.new(filename)
    @db.synchronous = 0
    @db.execute("pragma locking_mode = exclusive")
  end

  def self.create_tables
    @db.execute <<-EOF
      create table if not exists shapes (geokey text unique, name text, geojson blob)
    EOF
    @db.execute <<-EOF
      create table if not exists timestamps (path text unique, timestamp text)
    EOF
    @db.execute("create index if not exists geoidx on shapes (geokey)")
  end

  def self.insert_shape(geo_key, name, geometry)
    @db.execute("insert or replace into shapes values (?,?,?)",
      geo_key, name, geometry)
  end

  def self.find_shape(geo_key)
    ret = @db.execute("select name,geojson from shapes where geokey=?", geo_key)
    ret[0] if ret
  end

  def self.insert_timestamp(path, ts)
    @db.execute("insert or replace into timestamps values (?,?)", path, ts)
  end

  def self.find_timestamp(path)
    ret = @db.execute("select timestamp from timestamps where path=?", path)
    ret[0].to_s if ret
  end

  def self.check_time(shapefile_path, mt)
    last_mt = SqliteShapeDB.find_timestamp(shapefile_path)
    !last_mt || mt > last_mt
  end

end
