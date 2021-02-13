# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require_relative 'shorty'

Bundler.require(:default, :development)

run Shorty.app
