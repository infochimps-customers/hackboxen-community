require 'rake'
require 'yaml'
require 'rake/clean'
require 'json'
require 'configliere'
require 'swineherd'

HACKBOX_LIB_DIR = File.join(File.dirname(__FILE__), 'hackboxen')

WorkingConfig = Configliere::Param.new
WorkingConfig.use :commandline, :config_file

require 'hackboxen/utils'
require 'hackboxen/tasks'
