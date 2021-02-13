# frozen_string_literal: true

require 'spec_helper'
require 'rack'
require_relative '../../framework/router'

RSpec.describe Router do
  subject { described_class.new(env) }

  class TestController; end

  before do
    routes = [
      Route.new(
        method: :post,
        path: 'shorten',
        controller: :TestController,
        action: :create
      ),
      Route.new(
        method: :get,
        path: 'dummy/endpoint/:id',
        controller: :TestController,
        action: :stats
      ),
      Route.new(
        method: :get,
        path: 'sign_in/to/my_world',
        controller: :TestController,
        action: :show
      )
    ]

    stub_const('Router::ROUTES', routes)
  end

  describe '#resolve' do
    context 'when request matches a defined routed' do
      let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/dummy/endpoint/123' } }

      it 'returns controller, action and path params' do
        expect(subject.resolve).to eq([TestController, :stats, { 'id' => '123' }])
      end
    end

    context 'when request does not match any route' do
      let(:env) { { 'REQUEST_METHOD' => 'GET', 'PATH_INFO' => '/dummy/wrong/123' } }

      it 'returns nil' do
        expect(subject.resolve).to be_nil
      end
    end
  end
end
