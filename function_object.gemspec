# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'function_object/version'

Gem::Specification.new do |spec|
  spec.name          = 'function_object'
  spec.version       = FunctionObject::VERSION
  spec.authors       = ['Vladimir Kochnev']
  spec.email         = ['hashtable@yandex.ru']

  spec.summary       = 'Just nice callable objects, nothing else'
  spec.homepage      = 'https://github.com/marshall-lee/function_object'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'
end
