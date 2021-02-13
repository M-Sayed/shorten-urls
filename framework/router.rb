# frozen_string_literal: true

require_relative 'route'

class Router
  attr_reader :env

  ROUTES = [
    Route.new(
      method: :post,
      path: 'shorten',
      controller: :UrlsController,
      action: :create
    ),
    Route.new(
      method: :get,
      path: ':shortcode/stats',
      controller: :UrlsController,
      action: :stats
    ),
    Route.new(
      method: :get,
      path: ':shortcode',
      controller: :UrlsController,
      action: :show
    )
  ].freeze

  def initialize(env)
    @env = env
  end

  def resolve
    route = ROUTES.find { |route| route.matchs?(request) }

    return nil unless route

    [Object.const_get(route.controller), route.action, route.path_params]
  end

  private

  def request
    @request ||= Rack::Request.new(env)
  end
end
