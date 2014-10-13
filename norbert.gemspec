# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "Norbert"
  spec.version       = '0.1'
  spec.authors       = ["Christoph Eicke"]
  spec.email         = ["christoph@geisterstunde.org"]
  spec.summary       = %q{A little MP3 player to be deployed on the Raspberry Pi platform.}
  spec.description   = %q{A little MP3 player to be deployed on the Raspberry Pi platform that interfaces with a couple of buttons which are connected over the GPIO pins. It uses system calls to execute mpg123 on the Raspberry Pi system. It is tailored to be used by my daughter.}
  spec.homepage      = "https://github.com/ceicke/norbert"
  spec.license       = "MIT"

  spec.files         = ['lib/norbert.gpio.rb', 'lib/norbert.cmd.rb', 'lib/norbert/album.rb']
  spec.executables   = ['norbert.gpio', 'norbert.cmd']
  spec.test_files    = ['tests/test_norbert.rb']
  spec.require_paths = ["lib"]
end
