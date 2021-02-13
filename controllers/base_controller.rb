# frozen_string_literal: true

require 'json'

class BaseController
  attr_reader :params

  def initialize(params: {})
    @params = params
  end

  private

  def redirect_to(url, opts)
    [opts[:status], { 'Location' => url }, []]
  end

  def render(opts)
    [
      opts[:status],
      { 'Content-Type' => 'application/json' },
      [opts[:json].to_json]
    ]
  end
end
