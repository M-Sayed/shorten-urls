# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.1'

gem 'pg'
gem 'rack'
gem 'redis'
gem 'sequel'
gem 'thin'

group :development, :test do
  gem 'byebug'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rack'
  gem 'rack-env'
  gem 'rubocop', require: false
end

group :test do
  gem 'rspec'
  gem 'timecop'
end
