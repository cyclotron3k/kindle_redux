Gem::Specification.new do |spec|
	spec.name         = 'kindle_redux'
	spec.version      = '0.0.1'
	spec.date         = '2017-06-28'
	spec.summary      = 'A configurable renderer for kindles'
	spec.description  = 'A panel based content renderer'
	spec.authors      = 'cyclotron3k'
	spec.files        = ['lib/kindle_redux.rb', 'Rakefile', 'kindle_redux.gemspec', 'README.md']
	spec.test_files   = ['test/test_kindle_redux.rb']
	spec.homepage     = 'https://github.com/cyclotron3k/kindle_redux'
	spec.license      = 'MIT'

	spec.required_ruby_version = '>= 1.9.0'

	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "minitest", "~> 5.0"

	spec.add_runtime_dependency 'open-uri'
	spec.add_runtime_dependency 'nokogiri'
	spec.add_runtime_dependency 'digest/md5'
	spec.add_runtime_dependency 'evernote-thrift'
	spec.add_runtime_dependency 'parallel'
	spec.add_runtime_dependency 'google/apis/calendar_v3'
	spec.add_runtime_dependency 'googleauth'
	spec.add_runtime_dependency 'googleauth/stores/file_token_store'
	spec.add_runtime_dependency 'fileutils'
	spec.add_runtime_dependency 'rasem' '~> 0.7'

end