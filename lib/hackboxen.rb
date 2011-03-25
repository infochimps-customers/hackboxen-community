require 'rake'
require 'yaml'
require 'rake/clean'
require 'json'
require 'configliere'
require 'swineherd'

HACKBOX_LIB_DIR = File.join(File.dirname(__FILE__), 'hackboxen')

Settings.use :commandline, :config_file
# Gives you all the basic hackboxen tasks namespaced under 'hb'
require 'hackboxen/utils'
require 'hackboxen/tasks'
