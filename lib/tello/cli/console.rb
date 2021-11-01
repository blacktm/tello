#!/usr/bin/env ruby

if $tello_testing
  puts "⚠️  Test mode enabled"
  r_module = 'tello/cli/testing'
else
  r_module = 'tello'
end

puts %Q(Ready to receive Tello#{$edu} commands. Type "exit" to quit.)

if system('pry -v &>/dev/null')
  system("pry -r #{r_module}")
else
  system("irb -r #{r_module}")
end
