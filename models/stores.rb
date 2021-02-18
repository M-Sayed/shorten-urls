# frozen_string_literal: true

require_relative '../commons/database'

module Stores
  def cache_store
    @cache_store ||= Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])
  end

  def db_store
    return @db_store if @db_store

    Database.configure({
                         adapter: :postgres,
                         user: ENV['DB_USERNAME'],
                         password: ENV['DB_PASSWORD'],
                         host: ENV['DB_HOST'],
                         port: ENV['DB_PORT'],
                         database: ENV['DB_NAME'],
                         max_connections: 10
                       })

    @db_store = Database.instance
  end
end
