require 'rubygems'
require 'yaml'
require 'rake'
require 'configliere'
require 'ohai'
require 'lib/hackboxen/template' # For creating hackbox scaffolding

Settings.use :commandline
Settings.define :dataroot,  :default  => '/data/hb', :description => "Global hackbox dataroot"
Settings.define :namespace, :default  => 'test',     :description => "Hackbox namespace (eg. web/analytics)"
Settings.define :protocol,  :default  => 'foobar',   :description => "Hackbox protocol (eg. digital_element)"
Settings.resolve!

#
# Sets up your ~/.hackbox directory with basic config file. By default the
# dataroot for all hackboxen is /data/hb. You'll want to chmod + chown this.
#
hackbox_dir    = File.join(ENV["HOME"], ".hackbox")
hackbox_config = File.join(hackbox_dir, "hackbox.yaml")

directory hackbox_dir

#
# Probes the system using ohai and populates minimal list of provides.
#
file hackbox_config => [hackbox_dir] do

  # Create config hash and setup defaults
  config_hash = {}
  config_hash['dataroot']          = Settings[:dataroot]
  config_hash['filesystems']       = {'local' => {}}
  config_hash['filesystem_scheme'] = 'file'
  #

  # ec2 setup if you've got it
  ec2_config = File.join(ENV["HOME"],'.hadoop-ec2/aws')
  Settings.merge! YAML.load(File.read(ec2_config)) if File.exists?(ec2_config)
  if Settings[:access_key] # you have an aws account setup
    config_hash['filesystems']['s3'] = {
        'access_key'        => Settings[:access_key],
        'secret_access_key' => Settings[:secret_access_key]
    }
  end
  #

  # probe system
  sys = Ohai::System.new
  sys.all_plugins
  config_hash['machine'] = sys[:kernel][:machine]
  config_hash['os']      = sys[:os]
  #

  File.open(hackbox_config, 'wb'){|f| f.puts config_hash.to_yaml}
end

# hb directories, where all the code for a hackbox lives
root        = "hb"
namespace   = File.join(root, Settings.namespace.gsub('.','/'))
protocol    = File.join(namespace, Settings.protocol)
engine      = File.join(protocol, "engine")
config      = File.join(protocol, "config")

# define idempotent directory tasks
[namespace, protocol, engine, config].each{|dir| directory dir}

# files
rakefile    = File.join(protocol, "Rakefile")
main        = File.join(engine, "main")
config_yml  = File.join(config, "config.yaml")

templates = File.join("lib/hackboxen/template")
# Create hb Rakefile if it doesn't already exist
file rakefile => protocol do
  HackBoxen::Template.new(File.join(templates, "Rakefile.erb"), rakefile, {}).substitute! unless File.exist?(rakefile)
end

# Create executable hb main file if it doesn't already exist
file main => engine do
  unless File.exist?(main)
    HackBoxen::Template.new(File.join(templates, "main.erb"), main, {}).substitute!
    File.chmod(0755, main)
  end
end

# Create minimal config file if it doesn't already exist
file config_yml => config do
  # FIXME: Not everyone will have a local filesystem
  min_config = {'namespace' => Settings.namespace, 'protocol' => Settings.protocol, 'filesystem_scheme' => 'file'}
  File.open(config_yml, 'w'){|f| f.puts(min_config.to_yaml)} unless File.exist?(config_yml)
end


desc "Setup hackbox.yaml in ~/.hackbox/hackbox.yaml"
task :install  => [hackbox_config]
desc "Scaffold in the required hackbox structure for a new hackbox along with stubbed out files. Requires namespace and protocol. \nUSAGE: rake scaffold -- --namespace=[namespace] --protocol=[protocol]"
task :scaffold => [rakefile, main, config_yml]
