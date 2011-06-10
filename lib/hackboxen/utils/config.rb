module HackBoxen

  #
  # For reading in config from the disk and merging with the <tt>Settings</tt> hash
  #
  class Config

    #
    # Merge all of the valid yaml files in "path"  with the "config" hash
    #
    def self.read_config_dir path, filesystem_scheme
      fs = Swineherd::FileSystem.get(filesystem_scheme)
      return unless fs.exists? path
      fs.entries(path).sort.each do |filename|  # We want a well defined merge order
        begin
          if filename.downcase.end_with? ".yaml"
            contents = fs.open(File.join(path,filename)).read
            WorkingConfig.deep_merge!(YAML.load(contents))
            fs.close
          end
        rescue
          puts "Bad config file #{File.join(path,filename)}. Skipping."
        end
      end
    end

  end

  #
  #  Used to make sure the required resources for a hackbox are available in the execution environment
  #
  class ConfigValidator

    # This makes sure the "requires" are met by the "provides"
    # in the hackbox config. Failures are stored in <tt>fails</tt>.
    def self.failed_requirements
      p = WorkingConfig['provides']
      r = WorkingConfig['requires']
      fails = []
      if r != nil
        if not r.class == Hash  or not p.class == Hash
          fails << "'requires' and 'provides' must be Hash"
        else
          fails += self.match_requirements r, p
        end
      end
      fails
    end

    # Recursive. r and p must be hashes.
    def self.match_requirements r,p,path=""
      fails = []
      r.keys.each { |k|
        if not p.has_key? k
          fails << "Missing #{path}/#{k}"
        else
          if r[k].class == Hash
            if p[k].class != Hash
              fails << "'provides' #{path}/#{k} should be a hash because 'requires' is."
            else
              fails += self.match_requirements r[k],p[k],"#{path}/#{k}"
            end
          end
        end
      }
      fails
    end
  end

end
