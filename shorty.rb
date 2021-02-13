require_relative 'controllers/urls_controller'
require_relative 'framework/router'

class Shorty
  class << self
    def app
      @app ||= Rack::Builder.new do
        run ->(env) do
          controller, action, path_params = Router.new(env).resolve
          
          # if the path is not defined, respond w/ 404
          # otherwise, call the corresponding action
          if controller.nil? || action.nil?
            [
              404,
              { 'Content-Type' => 'application/json'},
              ["{\"message\": \"Where are you going? it is not your home nor your people\"}"]
            ]
          else
            request = Rack::Request.new(env)
            req_params = (JSON.parse(request.body.read) if request.post?) || {}

            controller.new(params: req_params.merge(path_params)).public_send(action)
          end
        end
      end
    end
  end
end