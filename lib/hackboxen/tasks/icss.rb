namespace :hb do

  desc "Creates an Icss file from a config.yaml file, inside a hackbox directory"
  task :icss, [:destdir] do |t, args|
    args.destdir ? dest = args.destdir : dest = HackBoxen::Paths.fixd_dir
    cfg_yml = File.join(Dir.pwd, 'config/config.yaml')
    raise "There is no config.yaml nearby!" unless File.exists? cfg_yml
    icss = Icss::Protocol.receive YAML.load(File.read cfg_yml)
    file_name = icss.protocol + '.icss.json'
    fs = Swineherd::FileSystem.get(WorkingConfig[:filesystem_scheme])
    fs.open(File.join(dest, file_name), 'w') do |file|
      file.puts icss.to_hash.to_json
    end
  end

end
