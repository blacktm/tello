# Tello module and requires

module Tello
  # Flag for testing
  attr_accessor :testing, :os, :ip, :port

  def self.testing; @testing end
  def self.testing=(t); @testing=(t) end
  def self.os; @os end

  # Set the operating system
  case RUBY_PLATFORM
  when /darwin/
    @os = :macos
  when /linux/
    @os = :linux
  when /mingw/
    @os = :windows
  end
end

require 'tello/colorize'
require 'tello/state'
require 'tello/wifi'
require 'tello/client'
require 'tello/dsl'

# Add DSL
extend Tello::DSL
