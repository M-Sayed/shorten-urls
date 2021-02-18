# frozen_string_literal: true

require_relative 'base_controller'
require_relative '../models/link'

class UrlsController < BaseController
  include Stores

  # TODO: move to a service object.
  def create
    shortcode = params['shortcode']
    url = params['url']

    shortcode_used = cache_store.exists?(shortcode) ||
                     db_store[:links].where(shortcode: shortcode).count.positive?
    error_msg = nil
    status    = 201

    if url.nil?
      status = 400
      error_msg = 'url is not present'
    elsif shortcode_used
      status = 409
      error_msg = 'The the desired shortcode is already in use. Shortcodes are case-sensitive'
    elsif shortcode && shortcode !~ Link::SHORTCODE_REGEX
      status = 422
      error_msg = 'The shortcode fails to meet the following regexp: ^[0-9a-zA-Z_]{4,}$.'
    else
      shortcode ||= Link.generate_shortcode!

      Link.create(shortcode, url)
    end

    if error_msg
      render status: status, json: { error: error_msg }
    else
      render status: 201, json: { shortcode: shortcode }
    end
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

    if stats
      render status: 200, json: stats
    else
      render status: 404, json: { error: 'The shortcode cannot be found in the system' }
    end
  end
end
