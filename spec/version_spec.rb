require 'spec_helper'

describe Idhja22 do
  describe 'VERSION' do
    it 'should be current version' do
      Idhja22::VERSION.should == '0.8.0'
    end
  end
end