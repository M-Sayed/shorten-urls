# frozen_string_literal: true

class Route
  attr_reader :method, :path, :controller, :action

  def initialize(method:, path:, controller:, action:)
    @method = method
    @path = path
    @controller = controller
    @action = action
  end

  def matches?(request)
    request_path = request.path_info.delete_prefix('/')

    # if not the same method, return false.
    return false unless request.request_method.downcase.to_sym == method
    # if not the same path pattern, return false.
    return false unless same_pattern?(request_path)

    true
  end

  def path_params(request)
    return @path_params if @path_params

    request_path = request.path_info.delete_prefix('/')

    @path_params = extract_path_params(request_path)
  end

  private

  def same_pattern?(request_path)
    request_path_segements = request_path.split('/')
    route_path_segements   = path.split('/')

    return unless request_path_segements.size == route_path_segements.size

    request_path_segements.each.with_index do |request_segment, index|
      route_segment = route_path_segements[index]
      matched = route_segment.match(/^:(.*)/)

      return false unless matched || request_segment == route_segment
    end
  end

  def extract_path_params(request_path)
    request_path_segements = request_path.split('/')
    route_path_segements   = path.split('/')

    request_path_segements
      .each
      .with_index
      .each_with_object({}) do |(request_segment, index), params|
      route_segment = route_path_segements[index]
      matched = route_segment.match(/^:(.*)/)

      params[matched[1]] = request_segment if matched
    end
  end
end
