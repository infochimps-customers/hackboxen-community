require 'fileutils'

module HackBoxen

  # A factory function that returns an instance of the requested class
  def filesystem location
    if location == 'local'
      LocalFileSystem.new()
    elsif location.downcase == 'hdfs'
      nil
    elsif location.downcase == 's3'
      nil
    else
      nil
    end
  end
   
  class LocalFileSystem
    
    # Works like rm -r
    def rm(path)
      FileUtils.rm_r(path)
    end
    
    # Does this exist?
    def exists?(path)
      File.exists?(path)
    end
    
    # Works like UNIX mv
    def mv(srcpath,dstpath)
      FileUtils.mv(srcpath,dstpath)
    end
    
    # Works like UNIX cp -r
    def cp(srcpath,dstpath)
      FileUtils.cp_r(srcpath,dstpath)
    end
    
    # Make directory path if it does not (partly) exist
    def mkpath(path)
      FileUtils.mkpath
    end
    
    # Return file type ("dir" or "file" or "symlink")
    def type(path)
      if File.symlink?(path)
        return "symlink"
      end
      if File.directory?(path)
        return "directory"
      end
      if File.file?(path)
        return "file"
      end
      "unknown"
    end
    
    # Give contained files/dirs
    def entries(dirpath)
      if type(dirpath) != "directory"
        return nil
      end
      Dir.entries(dirpath)
    end
    
    class File
      attr_accessor :path, :scheme, :mode
      
      def initialize(path,scheme,mode="r")
        @path=path
        @scheme=scheme
        @mode=mode
        @handle=IO.open(path,mode)
      end
      
      def open(path,scheme,mode="r")
        # Only "r" and "w" modes are supported.
        # These are equivalent to "rb" and "wb" on a local filesystem.
        initialize(path,scheme,mode)
      end
      
      # Return whole file and as a string
      def read
        @handle.read
      end
      
      # Return a line from stream
      def readline
        @handle.gets
      end
      
      # Writes to the file
      def write(string)
        @handle.write(string)
      end
      
      # Close file
      def close
        @handle.close
      end
    end
  end
end
