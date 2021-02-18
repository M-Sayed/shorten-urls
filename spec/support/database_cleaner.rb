# frozen_string_literal: true

RSpec.configure do |config|
  config.before :each do
    Database.instance[:links].delete
  end
end
