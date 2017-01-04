repository_name = `knife metadata name`
repository_name = repository_name.chomp.split[1]

task :noop do
  puts "building branch #{ENV['env.BRANCH_NAME']}"
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
