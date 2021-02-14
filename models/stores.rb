# frozen_string_literal: true

module Stores
  def cache_store
    @redis ||= Redis.new(host: 'localhost', port: 6379)
  end
end
