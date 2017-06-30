require 'rake/testtask'

task :default => 'test:unit'

desc "Launch an interactive Pry console"
task :console do
  exec "pry -r kindle_redux -I ./lib"
end