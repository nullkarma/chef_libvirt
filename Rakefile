#!/usr/bin/env rake

desc 'Foodcritic linter'
task :foodcritic do
  sh 'foodcritic -f any .'
end

# rubocop rake task
desc 'Ruby style guide linter'
task :rubocop do
  sh 'rubocop'
end

# default tasks are quick, commit tests
task default: %w(foodcritic rubocop)
