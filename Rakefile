require_relative 'lib/tello/colorize'
require_relative 'lib/tello/version'

# Helpers

def print_task(task)
  print "\n", "==> ".blue, task.bold, "\n\n"
end

def run_cmd(cmd)
  puts "==> #{cmd}\n"
  system cmd
end

# Tasks

task default: 'all'

desc "Uninstall gem"
task :uninstall do
  print_task "Uninstalling"
  run_cmd "gem uninstall tello --executables"
end

desc "Build gem"
task :build do
  print_task "Building"
  run_cmd "gem build tello.gemspec --verbose"
end

desc "Install gem"
task :install do
  print_task "Installing"
  run_cmd "gem install tello-#{Tello::VERSION}.gem --local --verbose"
end

desc "Uninstall, build, install, and test"
task :all do
  Rake::Task['uninstall'].invoke
  Rake::Task['build'].invoke
  Rake::Task['install'].invoke
end
