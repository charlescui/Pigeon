# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pigeon/version'

Gem::Specification.new do |spec|
  spec.name          = "pigeon"
  spec.version       = Pigeon::VERSION
  spec.authors       = ["崔峥"]
  spec.email         = ["zheng.cuizh@gmail.com"]

  spec.summary       = %q{搜索字符串中省市信息，返回对应的省市坐标和行政区划代码.}
  spec.description   = %q{自带省市词库，以及行政区划代码库}
  spec.homepage      = ""
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'activesupport', '~>4.2.6'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'thor'
  spec.add_development_dependency 'patron'
end
