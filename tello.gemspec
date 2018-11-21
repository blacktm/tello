require_relative 'lib/tello/version'

Gem::Specification.new do |s|
  s.name        = 'tello'
  s.version     = Tello::VERSION
  s.summary     = 'Tello'
  s.description = 'Fly the Tello drone with Ruby!'
  s.homepage    = 'https://github.com/blacktm/tello'
  s.license     = 'MIT'
  s.author      = 'Tom Black'
  s.email       = 'tom@blacktm.com'
  s.files = Dir.glob('lib/**/*')
  s.executables << 'tello'
end
