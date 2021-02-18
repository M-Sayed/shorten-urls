# frozen_string_literal: true

require 'sequel'

class Database
  class << self
    def configure(configs = {})
      @configs = configs
    end

    def instance
      Sequel.connect(@configs)
    end

    def setup
      return if instance.table_exists?(:links)

      instance.create_table :links do
        primary_key :id
        String :shortcode, index: { unique: true }
        String :url
        Integer :redirectCount
        DateTime :lastSeenDate
        DateTime :startDate
      end
    end
  end
end
