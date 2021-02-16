# frozen_string_literal: true

require 'spec_helper'
require_relative '../../controllers/base_controller'

RSpec.describe BaseController do
  subject { described_class.new(params: {}) }

  describe '.redirect_to' do
    it 'returns Location header w/ given url' do
      header = subject.send(:redirect_to, 'url.com', { status: 302 })[1]
      expect(header).to eq({ 'Location' => 'url.com' })
    end

    it 'returns empty body' do
      body = subject.send(:redirect_to, 'url.com', { status: 302 })[2]
      expect(body).to eq([])
    end

    it 'responds with 302' do
      status = subject.send(:redirect_to, 'url.com', { status: 302 })[0]
      expect(status).to eq(302)
    end
  end

  describe '.render' do
    it 'returns Content-Type header w/ application/json' do
      header = subject.send(:render, status: 200, json: { data: 'data' })[1]
      expect(header).to eq({ 'Content-Type' => 'application/json' })
    end

    it 'returns right body' do
      body = subject.send(:render, status: 200, json: { data: 'data' })[2]
      expect(body).to eq([{ data: 'data' }.to_json])
    end

    it 'responds with 200' do
      status = subject.send(:render, status: 200, json: { data: 'data' })[0]
      expect(status).to eq(200)
    end
  end
end
