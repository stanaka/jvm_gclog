# -*- coding:utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["stanaka"]
  gem.email         = ["shinji.tanaka@gmail.com"]
  gem.description   = %q{JavaVM gc.log parser.}
  gem.summary       = %q{JavaVM gc.log parser.}
  gem.homepage      = "https://github.com/stanaka/jvm_gclog"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "jvm_gclog"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.2"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
                                           
