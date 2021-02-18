# frozen_string_literal: true

require 'securerandom'
require_relative 'stores'

class Link
  SHORTCODE_REGEX = /^[0-9a-zA-Z_]{6}$/.freeze

  class << self
    include Stores

    def create(shortcode, url)
      url_info = {
        'url' => url_with_protocol(url),
        'startDate' => Time.now,
        'lastSeenDate' => nil,
        'redirectCount' => 0
      }

      cache_store.set(shortcode, Marshal.dump(url_info))
      # possible to run the following in bg job.
      db_store[:links].insert({ shortcode: shortcode }.merge(url_info))
    end

    def retrive_url(shortcode)
      url_info = load(shortcode)

      return nil unless url_info

      url_info['redirectCount'] += 1
      url_info['lastSeenDate'] = Time.now

      cache_store.set(shortcode, Marshal.dump(url_info))
      # possible to run the following in bg job.
      db_store[:links].where(shortcode: shortcode)
                      .update(
                        'redirectCount' => url_info['redirectCount'],
                        'lastSeenDate' => url_info['lastSeenDate']
                      )

      url_info['url']
    end

    def stats(shortcode)
      url_info = load(shortcode)

      url_info&.delete('url')

      url_info
    end

    def generate_shortcode!
      code = SecureRandom.alphanumeric(6)

      return generate_shortcode! if cache_store.exists?(code)

      code
    end

    private

    def load(shortcode)
      if cache_store.exists?(shortcode)
        Marshal.load(cache_store.get(shortcode))
      elsif link = db_store[:links].where(shortcode: shortcode).first
        {
          'url' => link[:url],
          'startDate' => link[:startDate],
          'lastSeenDate' => link[:lastSeenDate],
          'redirectCount' => link[:redirectCount]
        }
      end
    end

    def url_with_protocol(url)
      return url if url =~ /^(http)/

      "http://#{url}"
    end
  end
end
