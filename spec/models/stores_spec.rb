# frozen_string_literal: true

require 'spec_helper'
require_relative '../../models/stores'

RSpec.describe Stores do
  class TestClass
    include Stores
  end

  subject { TestClass.new }

  describe 'cache_store' do
    it 'responds to :cache_store' do
      expect(subject.respond_to?(:cache_store)).to be_truthy
    end

    it 'returns a redis instance' do
      expect(subject.cache_store).to be_an_instance_of(Redis)
    end
  end
end
