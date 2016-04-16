# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scrapey/constants', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["P Guardiario"]
  gem.email         = ["pguardiario@gmail.com"]
  gem.description   = %q{A simple scraping framework}
  gem.summary       = %q{A simple scraping framework}
  gem.homepage      = ""

#  gem.files         = `git ls-files`.split($\)
  gem.files         = `find * -type f | grep -v pkg`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scrapey"
  gem.require_paths = ["lib"]
  gem.version       = Scrapey::VERSION
  gem.add_dependency(%q<mechanize>)
end

