# frozen_string_literal: true

require_relative 'base_controller'
require_relative '../models/link'

class UrlsController < BaseController
  def create
    key = params['shortcode']
    url = params['url']

    Link.create(key, url)

    render status: 201, json: { message: 'created' }
  end

  def show
    url = Link.retrive_url(params['shortcode'])

    if url
      redirect_to url, status: 302
    else
      render status: 404, json: { error: 'The shortcode cannot be found in the system' }
    end
  end

  def stats
    stats = Link.stats(params['shortcode'])

    render status: 200, json: stats
  end
end
