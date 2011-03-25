module HackBoxen

class ConfigValidator

  def initialize
    @r = Settings['requires']
    @p = Settings['provides']
    @fails = []
  end
  
  # This makes sure the "requires" are met by the "provides"
  # in the hackbox config. Failures are stored in @fails.
  def missing_requirements
    if @r != nil
      if not @r.class == Hash  or not @p.class == Hash
        @fails << "'requires' and 'provides' must be Hash"
        return
      end
    
    match_requirements @r, @p
    @fails
  end

  # Recursive. r and p must be hashes.
  def match_requirements r,p,path=""
    r.each { |k|
      if not p.has_key? k
        @fails << "Missing #{path}/#{k}"
      else
        if r[k].class == Hash
          if p[k].class != Hash
            @fails << "'provides' #{path}/#{k} should be a hash because 'requires' is."
          else
            match_requirements r[k],p[k],"#{path}/#{k}"
          end
        end
      end
    }
  end
        
def run configfile
  config = File.open(configfile) { |f| JSON.parse(f.read()) }
  cf = ConfigValidator cf
  fails = cf.failed_requirements
  if fails.size == 0
    puts "Config file passes!"
  else
    puts "Config files fails with:"
    fails.each do |f|
      puts "   #{f}"
    end
  end
end

  
    
if __FILE__ == $0
  run
end

  
