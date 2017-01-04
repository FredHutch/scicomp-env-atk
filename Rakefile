repository_name = `knife metadata name`
#repository_name = repository_name.chomp.split[1]
branch = ENV['BRANCH_NAME']

task :noop do
  puts "building branch #{branch} in #{repository_name}"
  if branch == "prod"
    environment_name = "#{repository_name}"
  else
    environment_name = "#{repository_name}-#{branch}"
  end
  puts "applying branch to environment #{environment_name}"

end

task :apply do
  branches.each do |branch|
    environment_name = "#{repository_name}-#{branch}"
    puts "   INFO: applying environment #{environment_name}"
    sh %(git checkout #{branch})
    begin
      sh %(berks apply #{environment_name}) do |ok, result|
        if !ok
          puts "WARNING: apply of environment #{environment_name} "\
            'failed- possibly needs create?'
        else
          puts "   INFO: succeeded: #{result}"
        end
      end
      sh %(berks upload)
    end
  end
end
