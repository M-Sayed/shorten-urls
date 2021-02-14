# frozen_string_literal: true

class CacheStorage
  class << self
    def get(key)
      redis.get(key)
    end

    def put(key, value)
      redis.set(key, value)
    end

    private

    def redis
      @redis ||= Redis.new(host: 'localhost', port: 6379)
    end
  end
end