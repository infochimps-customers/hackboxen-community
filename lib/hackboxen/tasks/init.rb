require 'json'
require 'icss'

namespace :hb do
  #
  # Hackbox configuration is always read
  #
  puts "Reading hackbox configuration..."

  #
  # Read base config from default (local) filesystem
  #
  HackBoxen::Config.read_config_dir("/etc/hackbox", :file) if File.directory?('/etc/hackbox')
  HackBoxen::Config.read_config_dir(File.join(ENV['HOME'], ".hackbox"), :file) if ENV["HOME"]
  HackBoxen::Config.read_config_dir(File.join(HACKBOX_DIR, "config"), :file)

  task :paths do
    HackBoxen::Paths.maybe_make_required_paths
  end

  #
  # Save working config out into a file (always)
  #
  task :create_working_config => :paths do
    # Data specific config dir
    raise "Your hackbox config appears to be missing a [filesystem_scheme] eg. hdfs or file." unless WorkingConfig['filesystem_scheme']

    HackBoxen::Config.read_config_dir(HackBoxen::Paths.data_config_dir, WorkingConfig['filesystem_scheme'].to_sym) # <-- data specific override

    # Make sure our requirements are met
    failures = HackBoxen::ConfigValidator.failed_requirements
    if failures.size > 0
      raise "Hackbox environment fails to meet requirements:\n-- "+failures.join("\n-- ")+"\n"
    end

    fs = Swineherd::FileSystem.get(WorkingConfig['filesystem_scheme'].to_sym)
    fs.open(HackBoxen::Paths.working_config, 'w'){|f| f.write(WorkingConfig.to_hash.to_yaml)}
    fs.open(HackBoxen::Paths.working_config.sub('.yaml','.json'), 'w'){|f| f.write(WorkingConfig.to_hash.to_json)}
  end

  task :init => [:create_working_config] do
    main             = HackBoxen::Paths.hackbox_main
    hackbox_dataroot = HackBoxen::Paths.hackbox_dataroot
    fixd_dir         = HackBoxen::Paths.fixd_dir
    sh "#{main} #{hackbox_dataroot} #{fixd_dir}" do |ok,res|
      if !ok
        puts "Processing script failed with #{res}"
      end
    end
  end

end
