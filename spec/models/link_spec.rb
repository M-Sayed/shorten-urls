# frozen_string_literal: true

require 'spec_helper'
require_relative '../../models/link'

RSpec.describe Link, :redis_required do
  let(:redis) { Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT']) }
  let(:url) { 'example.com' }
  let(:url_with_protocol) { "http://#{url}" }
  let(:shortcode) { 'short1' }
  let(:time_now) { Time.now }

  before { Timecop.freeze(time_now) }
  after { Timecop.return }

  describe '.create' do
    it 'adds an entity for the shortcode in cache' do
      expect do
        described_class.create(shortcode, url)
      end.to change { redis.exists?(shortcode) }.from(false).to(true)
    end

    it 'writes correct data to redis' do
      described_class.create(shortcode, url)

      expect(Marshal.load(redis.get(shortcode))).to eq({
                                                         'url' => url_with_protocol,
                                                         'startDate' => time_now,
                                                         'lastSeenDate' => nil,
                                                         'redirectCount' => 0
                                                       })
    end
  end

  describe '.retrive_url' do
    context 'when shortcode exists' do
      before do
        redis.set(shortcode, Marshal.dump({
                                            'url' => url_with_protocol,
                                            'startDate' => time_now - 5 * 60 * 60,
                                            'lastSeenDate' => nil,
                                            'redirectCount' => 10
                                          }))
      end

      it 'returns corresponding url' do
        expect(described_class.retrive_url(shortcode)).to eq(url_with_protocol)
      end

      it 'updates lastSeenDate in url stats' do
        described_class.retrive_url(shortcode)

        stats = Marshal.load(redis.get(shortcode))
        expect(stats['lastSeenDate']).to eq(time_now)
      end

      it 'updates redirectCount in url stats' do
        described_class.retrive_url(shortcode)

        stats = Marshal.load(redis.get(shortcode))
        expect(stats['redirectCount']).to eq(11)
      end
    end

    context 'when shortcode does not exist' do
      it 'returns nil' do
        expect(described_class.retrive_url('not-existing-code')).to be_nil
      end
    end
  end

  describe '.stats' do
    before do
      redis.set(shortcode, Marshal.dump({
                                          'url' => url_with_protocol,
                                          'startDate' => time_now - 5 * 60 * 60,
                                          'lastSeenDate' => nil,
                                          'redirectCount' => 10
                                        }))
    end

    it 'returns url stats' do
      expect(described_class.stats(shortcode)).to eq({
                                                       'startDate' => time_now - 5 * 60 * 60,
                                                       'lastSeenDate' => nil,
                                                       'redirectCount' => 10
                                                     })
    end
  end
end
