# frozen_string_literal: true

require_relative 'database'

envfile = ".env.#{ENV['RACK_ENV']}"

if ::File.exist?(envfile)
  ::File.readlines(envfile).each do |line|
    next if line.chomp == '' || line =~ /^#/

    parts = line.chomp.split('=')

    ENV[parts[0]] = parts[1..].join('=')
  end
end

Database.configure(
  adapter: :postgres,
  user: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD'],
  host: ENV['DB_HOST'],
  port: ENV['DB_PORT'],
  database: ENV['DB_NAME'],
  max_connections: 10
)

Database.setup
