# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rack/env'
require_relative 'shorty'

ENV['RACK_ENV'] ||= 'development'

Bundler.require(:default, ENV['RACK_ENV'])

use Rack::Env, envfile: ".env.#{ENV['RACK_ENV']}" unless ENV['RACK_ENV'] == 'production'

run Shorty.app
