# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rack/env'
require_relative 'shorty'

Bundler.require(:default, :development)

use Rack::Env, envfile: ".env.#{ENV['RACK_ENV']}" unless ENV['RACK_ENV'] == 'production'

run Shorty.app
