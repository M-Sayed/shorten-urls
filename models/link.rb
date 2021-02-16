# frozen_string_literal: true

require_relative 'stores'

class Link
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
    end

    def retrive_url(shortcode)
      url_info = load(shortcode)

      return nil unless url_info

      url_info['redirectCount'] += 1
      url_info['lastSeenDate'] = Time.now

      cache_store.set(shortcode, Marshal.dump(url_info))

      url_info['url']
    end

    def stats(shortcode)
      url_info = load(shortcode)

      url_info.delete('url')

      url_info
    end

    private

    def load(shortcode)
      if cache_store.exists?(shortcode)
        Marshal.load(cache_store.get(shortcode))
      else
        # load from DB.
      end
    end

    def url_with_protocol(url)
      return url if url =~ /^(http)/

      "http://#{url}"
    end
  end
end
