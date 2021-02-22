# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/urls_controller'

RSpec.describe UrlsController, :redis_required do
  let(:redis) { Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT']) }
  let(:response) { Struct.new(:status, :headers, :body).new(*subject) }

  describe 'create' do
    let(:shortcode) { 'examp1' }
    let(:url) { 'http://example.com' }
    let(:params) { { 'shortcode' => shortcode, 'url' => url } }

    subject { described_class.new(params: params).create }

    context 'when params are valid' do
      context 'when shortcode is provided and it is not used' do
        it 'creates a shortend urls w/ given shortcode' do
          expect { subject }.to change { redis.exists?(shortcode) }.from(false).to(true)
          expect(Link.retrive_url(shortcode)).to eq(url)
        end
      end

      context 'when shortcode is not provided' do
        before do
          params.delete('shortcode')
          allow(Link).to receive(:generate_shortcode!).and_return('AxeMan')
        end

        it 'creates a shortend urls w/ a randomly generated code' do
          expect(Link).to receive(:generate_shortcode!)
          expect(response.body).to eq([{ shortcode: 'AxeMan' }.to_json])
          expect(Link.retrive_url('AxeMan')).to eq(url)
        end
      end
    end

    context 'when params are invalid' do
      context 'when url is NOT provided' do
        before { params.delete('url') }

        it 'does not create a shortend url' do
          expect { subject }.not_to change { redis.exists?(shortcode) }
          expect(redis.exists?(shortcode)).to be_falsy
        end

        it 'responds w/ 400' do
          expect(response.status).to eq(400)
        end

        it 'renders a message error' do
          expect(response.body).to \
            eq([{ error: 'url is not present' }.to_json])
        end
      end

      context 'when shortcode is provided and used before' do
        before { Link.create(shortcode, 'another-url.com') }

        it 'does not change the url for the existing shortcode' do
          expect(redis.exists?(shortcode)).to be_truthy
          expect(Link.retrive_url(shortcode)).to eq('http://another-url.com')
        end

        it 'responds w/ 409' do
          expect(response.status).to eq(409)
        end

        it 'renders a message error' do
          expect(response.body).to \
            eq([{ error: 'The the desired shortcode is already in use. Shortcodes are case-sensitive' }.to_json])
        end
      end

      context 'when shortcode does not meet its specifications' do
        before { params['shortcode'] = 'long_shortcode' }
        it 'does not create a shortend url' do
          expect { subject }.not_to change { redis.exists?(shortcode) }
          expect(redis.exists?(shortcode)).to be_falsy
        end

        it 'responds w/ 422' do
          expect(response.status).to eq(422)
        end

        it 'renders a message error' do
          expect(response.body).to \
            eq([{ error: 'The shortcode fails to meet the following regexp: ^[0-9a-zA-Z_]{4,}$.' }.to_json])
        end
      end
    end
  end

  describe 'show' do
    let(:shortcode) { 'examp1' }
    let(:url) { 'http://example.com' }
    let(:params) { { 'shortcode' => shortcode } }

    subject { described_class.new(params: params).show }

    context 'when provided shortcode exists' do
      before { Link.create(shortcode, url) }

      it 'redirects to url' do
        expect(response.headers).to eq({ 'Location' => url })
        expect(response.status).to eq(302)
      end
    end

    context 'when provided shortcode does not exist' do
      it 'responds with 404' do
        expect(response.status).to eq(404)
      end

      it 'reponds with error message' do
        expect(response.body).to \
          eq([{ error: 'The shortcode cannot be found in the system' }.to_json])
      end
    end
  end

  describe 'stats' do
    let(:shortcode) { 'examp1' }
    let(:url) { 'http://example.com' }
    let(:params) { { 'shortcode' => shortcode } }
    let(:stats) do
      {
        'url' => url,
        'startDate' => Time.now - 5 * 60 * 60,
        'lastSeenDate' => Time.now - 2 * 60 * 60,
        'redirectCount' => 20
      }
    end

    subject { described_class.new(params: params).stats }

    context 'when provided shortcode exists' do
      before do
        Link.create(shortcode, url)
        allow(Link).to receive(:stats).with(shortcode).and_return(stats)
      end

      it 'responds with correct stats' do
        expect(response.body).to eq([stats.to_json])
      end
    end

    context 'when provided shortcode does not exist' do
      it 'responds with 404' do
        expect(response.status).to eq(404)
      end

      it 'reponds with error message' do
        expect(response.body).to \
          eq([{ error: 'The shortcode cannot be found in the system' }.to_json])
      end
    end
  end
end
