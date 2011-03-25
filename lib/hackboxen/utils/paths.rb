module HackBoxen

  #
  # For handling directories etc
  #
  class Paths

    #
    # Returns path to the root of all **this** hackbox's output
    #
    def self.hackbox_dataroot
      raise "Your hackbox config appears to be missing a [dataroot] variable" unless Settings['dataroot']
      raise "Your hackbox appears to be missing a [namespace]" unless Settings['namespace']
      raise "Your hackbox appears to be missing a [protocol]" unless Settings['protocol']
      hackbox_dataroot = File.join(Settings['dataroot'], Settings['namespace'].gsub('.', '/'), Settings['protocol'])
      hackbox_dataroot
    end

    #
    # Use local filesystem to make hackbox_dirs (they're where code and config goes) and the given filesystem scheme to create other output dirs.
    #
    def self.maybe_make_required_paths
      raise "Your hackbox config appears to be missing a [filesystem_scheme] eg. hdfs or file." unless Settings['filesystem_scheme']
      otherfs = Swineherd::FileSystem.get(Settings['filesystem_scheme'].to_sym)
      localfs = Swineherd::FileSystem.get(:file)
      hackbox_dirs.each{|d| localfs.mkpath(d) unless localfs.exists? d}
      (input_dirs + output_dirs).each{|d| otherfs.mkpath(d) unless otherfs.exists? d}
    end

    #
    # Returns an array of output paths. These are created if they don't already exist.
    #
    def self.output_dirs
      [
        hackbox_dataroot,
        data_config_dir,
        working_config_dir,
        fixd_dir,
        log_dir,
      ]
    end

    #
    # Returns an array of the input directories
    #
    def self.input_dirs
      [
        hackbox_dataroot,
        ripd_dir,
        rawd_dir
      ]
    end

    #
    # Returns path to final output path (fixd)
    #
    def self.fixd_dir
      File.join(hackbox_dataroot, "fixd")
    end

    #
    # Returns path to data config dir (for overrides specific to data)
    #
    def self.data_config_dir
      File.join(hackbox_dataroot, "config")
    end

    #
    # Returns path to data config dir (for overrides specific to data)
    #
    def self.working_config_dir
      File.join(fixd_dir, "env")
    end
    
    #
    # Returns path to full working config
    #
    def self.working_config
      File.join(working_config_dir, "working_environment.yaml")
    end

    #
    # Returns path to place for raw intermediate (but useful) products
    #
    def self.rawd_dir
      File.join(hackbox_dataroot, "rawd")
    end

    #
    # Returns path to place for ripd (virginal downloaded) data files
    #
    def self.ripd_dir
      File.join(hackbox_dataroot, "ripd")
    end

    #
    # Returns path to place for log output
    # 
    def self.log_dir
      File.join(hackbox_dataroot, "log")
    end

    #
    # Returns path to place for truly ephemeral output
    #
    def self.tmp_dir
      File.join(hackbox_dataroot, "tmp")
    end
    
    #
    # Returns an array of the hackbox's own directories
    #
    def self.hackbox_dirs
      [File.join(HACKBOX_DIR, "engine"), File.join(HACKBOX_DIR, "config")] 
    end

    #
    # Returns the path to the hackbox engine directory
    #
    def self.hackbox_engine
      File.join(HACKBOX_DIR, "engine")
    end
    
    #
    # Returns the path to the hackbox executable
    #
    def self.hackbox_main
      File.join(self.hackbox_engine, "main")
    end
    
  end
  
end
