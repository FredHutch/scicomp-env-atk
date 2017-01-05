require 'tempfile'
require 'chef/cookbook/metadata'
require 'json'

metadata_file = 'metadata.rb'
metadata = Chef::Cookbook::Metadata.new
metadata.from_file(metadata_file)

repository_name = metadata.name
cookbook_version = metadata.version

branch = ENV['BRANCH_NAME']

task :noop do
  puts "building branch #{branch} in #{repository_name}"
  if branch == "prod"
    environment_name = "#{repository_name}"
  else
    environment_name = "#{repository_name}-#{branch}"
  end
  if File.exists?"Berksfile.lock"
    puts "updating berksfile"
  else
    puts "installing berksfile"
  end
  puts "building environment file"
  environment_file = Tempfile.new([environment_name, '.json'])
  puts "writing to #{environment_file.path}"
  environment_attrs = {}

  puts "... setting name and description"
  environment_attrs['name'] = environment_name
  environment_attrs['description'] = metadata.description
  environment_attrs['json_class'] = 'Chef::Environment'
  environment_attrs['chef_type'] = 'environment'
  environment_attrs['cookbook_versions'] = {}
  environment_attrs['default_attributes'] = {}
  environment_attrs['override_attributes'] = {}

  puts "... adding environment attributes (later- feature not ready)"

  puts "writing environment file"
  environment_file.write(environment_attrs.to_json)
  environment_file.close()

  puts "installing version pins"
  sh %(berks apply #{environment_name} -f #{environment_file.path})

  puts "uploading cookbooks to chef server"
  sh %(berks upload)

  puts "applying branch to environment #{environment_name}"
  sh %(knife environment from file #{environment_file.path})

end

