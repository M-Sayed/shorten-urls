# frozen_string_literal: true

class Shorty
  class << self
    def app
      @app ||= Rack::Builder.new do
        run lambda { |_env|
          [
            404,
            { 'Content-Type' => 'application/json' },
            ['{"message": "Where are you going? it is not your home nor your people"}']
          ]
        }
      end
    end
  end
end
