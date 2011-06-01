require 'json'
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

  HackBoxen::Paths.maybe_make_required_paths

  #
  # Save working config out into a file (always)
  #
  task :create_working_config do
    # Data specific config dir
    raise "Your hackbox config appears to be missing a [filesystem_scheme] eg. hdfs or file." unless Settings['filesystem_scheme']

    HackBoxen::Config.read_config_dir(HackBoxen::Paths.data_config_dir, Settings['filesystem_scheme'].to_sym) # <-- data specific override

    # Make sure our requirements are met
    failures = HackBoxen::ConfigValidator.failed_requirements
    if failures.size > 0
      raise "Hackbox environment fails to meet requirements:\n-- "+failures.join("\n-- ")+"\n"
    end

    fs = Swineherd::FileSystem.get(Settings['filesystem_scheme'].to_sym)
    fs.open(HackBoxen::Paths.working_config, 'w'){|f| f.write(Settings.to_hash.to_yaml)}
    fs.open(HackBoxen::Paths.working_config.sub('.yaml','.json'), 'w'){|f| f.write(Settings.to_hash.to_json)}
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

  # Right now, this a simple way to generate an icss from a hackbox config
  task :icss do
    file_name = Settings['protocol'] + '.icss.json'
    File.open(File.join(HACKBOX_DIR, file_name), "w") do |file|
      file.puts Settings.to_json
    end
  end

  task :create_mini, :data, :fs do |t, args|
    fs = Swineherd::FileSystem.get(args.fs.to_sym)
    s3 = Swineherd::FileSystem.get(:s3, Settings['aws']['access_key'], Settings['aws']['secret_key'])
    s3_path = File.join("s3://", Settings['aws']['s3_bucket'], "mini/hb", Settings['namespace'], Settings['protocol'], File.basename(args.data))
    puts s3_path
    s3.mkpath(s3_path)
    s3_file = s3.open(s3_path, 'w')
    s3_file.puts(fs.read)
    s3_file.close
  end

end
