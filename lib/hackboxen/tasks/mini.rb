require 'configliere'
require 'swineherd'

namespace :hb do

  Opts = Configliere::Param.new.use :commandline
  Opts.define :files, :type => Array
  Opts.resolve!

  desc "Stores a mini data set from the local filesystem into s3 for running a hackbox in mini mode"
  task :create_mini do |t,args|
    Opts[:files].each do |input|
      File.directory? input ? output = expected_mini_data + '/' : output = File.join(expected_mini_data, File.basename(input))
      sh "s3cmd put -r #{input} #{output}"
    end
  end

  task :run_mini do
    WorkingConfig[:dataroot] = "/data/mini/hb"
    dest = File.join(WorkingConfig[:dataroot], hackbox_name)
    raise "Expected mini data has not yet been created" unless s3fs.exists? expected_mini_data.gsub(/s3:\/\//,'')
    Rake::Task[:get_data].clear_actions
    Rake::Task['hb:create_working_config'].invoke
    if WorkingConfig[:filesystem_scheme] == 'hdfs'
      sh "hadoop fs -cp #{expected_mini_data.gsub(/s3:/, 's3n:')} #{dest}"
    elsif WorkingConfig[:filesystem_scheme] == 'file'
      sh "s3cmd sync #{expected_mini_data} #{dest}"
    end
    Rake::Task[:default].invoke
  end

end

def expected_mini_data
  File.join(WorkingConfig['s3_filesystem.mini_bucket'], hackbox_name, 'ripd')
end

def hackbox_name
  File.join(WorkingConfig[:namespace].gsub(/\./, '/'), WorkingConfig[:protocol])
end

def s3fs
  @s3fs ||= Swineherd::FileSystem.get(:s3, WorkingConfig['s3_filesystem.access_key'], WorkingConfig['s3_filesystem.secret_key'])
end
