# frozen_string_literal: true

require 'spec_helper'
require_relative '../../framework/route'

RSpec.describe Route do
  describe '#matches?' do
    let(:request) { double }

    subject do
      described_class.new(
        method: :get,
        path: 'users/:id/codes/:code',
        controller: :urls_controller,
        action: :dummy
      )
    end

    context 'when request method is different' do
      before do
        allow(request).to receive(:path_info).and_return('users/1/codes/shortcode')
        allow(request).to receive(:request_method).and_return('POST')
      end

      it 'returns false' do
        expect(subject.matches?(request)).to be_falsey
      end
    end

    context 'when request path pattern is different' do
      before do
        allow(request).to receive(:path_info).and_return('users/1/wrong-segment/shortcode')
        allow(request).to receive(:request_method).and_return('GET')
      end

      it 'returns false' do
        expect(subject.matches?(request)).to be_falsey
      end
    end

    context 'when both path and method matches' do
      before do
        allow(request).to receive(:path_info).and_return('users/1/codes/shortcode')
        allow(request).to receive(:request_method).and_return('GET')
      end

      it 'returns true' do
        expect(subject.matches?(request)).to be_truthy
      end
    end
  end

  describe '#path_params' do
    let(:request) { double }

    context 'when path contains params' do
      subject do
        described_class.new(
          method: :get,
          path: 'users/:id/codes/:code',
          controller: :urls_controller,
          action: :dummy
        )
      end

      before { allow(request).to receive(:path_info).and_return('/users/1/codes/shortcode') }

      it 'returns params passed in the request path' do
        expect(subject.path_params(request)).to eq({ 'id' => '1', 'code' => 'shortcode' })
      end
    end

    context 'when path does not contain params' do
      subject do
        described_class.new(
          method: :get,
          path: 'path/without/params',
          controller: :urls_controller,
          action: :dummy
        )
      end

      before { allow(request).to receive(:path_info).and_return('/path/without/params') }

      it 'returns params passed in the request path' do
        expect(subject.path_params(request)).to eq({})
      end
    end
  end
end
