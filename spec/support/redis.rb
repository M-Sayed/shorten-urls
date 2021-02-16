# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :redis_required) { redis.flushdb }
  config.after(:each, :redis_required) { redis.quit }
end
