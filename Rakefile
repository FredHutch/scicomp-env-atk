require 'tempfile'
require 'chef/cookbook/metadata'
require 'chef/application/knife'
require 'json'

metadata_file = 'metadata.rb'
metadata = Chef::Cookbook::Metadata.new
metadata.from_file(metadata_file)

cookbook_name = metadata.name
cookbook_version = metadata.version

branch = ENV['BRANCH_NAME']

task :test do
  require 'foodcritic'
  require 'rubocop/rake_task'
  puts 'Running foodcritic'
  result = FoodCritic::Linter.new.check cookbook_paths: '.'
  if result.failed? || !result.warnings.empty?
    puts 'foodcritic failed:'
    puts result
    raise
  end
  puts 'Running rubocop'
  task = RuboCop::RakeTask.new
  # We probably should catch this error
  task.fail_on_error = true
  result = task.run_main_task(false)
  puts result
end

task :build do
  require 'git'
  g = Git.init('.')
  if g.ls_files('Berksfile.lock').empty?
    Rake::Task['build_cookbook'].invoke
  else
    Rake::Task['build_environment'].invoke
  end
end

task :build_environment do
  puts "building branch #{branch} in #{cookbook_name}"
  environment_name = case branch
                     when 'prod'
                       cookbook_name
                     else
                       "#{cookbook_name}-#{branch}"
                     end

  puts 'updating berksfile'
  sh %(berks update)

  puts 'installing berksfile'
  sh %(berks install)

  puts 'building environment file'
  environment_file = Tempfile.new([environment_name, '.json'])
  puts "writing to #{environment_file.path}"
  environment_attrs = {}

  puts '... setting name and description'
  environment_attrs['name'] = environment_name
  environment_attrs['description'] = metadata.description
  environment_attrs['json_class'] = 'Chef::Environment'
  environment_attrs['chef_type'] = 'environment'
  environment_attrs['cookbook_versions'] = {}
  environment_attrs['default_attributes'] = {}
  environment_attrs['override_attributes'] = {}

  puts '... adding environment attributes (later- feature not ready)'

  puts 'writing environment file'
  environment_file.write(environment_attrs.to_json)
  environment_file.close

  puts 'installing version pins'
  sh %(berks apply #{environment_name} -f #{environment_file.path})

  puts 'uploading cookbooks to chef server'
  sh %(berks upload)

  puts "applying branch to environment #{environment_name}"
  sh %(knife environment from file #{environment_file.path})
end

task :build_cookbook do
  require 'git'
  require 'json'
  if branch != 'prod'
    puts 'not building non-production branch'
    next
  end
  puts "building branch #{branch} of cookbook #{cookbook_name}"
  puts "cookbook version (from metadata.rb) is #{cookbook_version}"
  puts 'searching for matching version tag in repository'
  g = Git.init('.')
  repo_tags = g.tags
  match_tags = repo_tags.find { |t| t.name == cookbook_version }
  unless match_tags.nil?
    puts "Matched tag #{match_tags.name} - cant build"
    raise
  end

  puts 'searching for matching version on server'
  subcommand = "cookbook show #{cookbook_name}"
  output = `knife #{subcommand}`
  versions = output.split
  if versions.include? cookbook_version
    puts "version #{cookbook_version} exists on server"
    raise
  end

  puts 'searching for matching version in supermarket'
  subcommand = "supermarket show #{cookbook_name} -F json"
  output = `knife #{subcommand}`
  output = JSON.parse(output)
  if output['metrics']['downloads']['versions'].key?(cookbook_version)
    puts "version #{cookbook_version} exists in supermarket"
    raise
  end

  puts 'tagging and pushing tag upstream'
  g.add_tag(
    cookbook_version,
    message: "Version #{cookbook_version} tagged by automatic-garbanzo"
  )
  g.push('origin', "refs/tags/#{cookbook_version}", f: true)

  puts 'uploading to server'
  subcommand = "cookbook upload #{cookbook_name} -o .."
  output = `knife #{subcommand}`
  puts output

  puts 'uploading to supermarket'
  subcommand = "supermarket share #{cookbook_name} -o .."
  output = `knife #{subcommand}`
  puts output

  puts 'done'
end
