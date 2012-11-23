require 'spec_helper'

describe Idhja22 do
  describe 'VERSION' do
    it 'should be current version' do
      Idhja22::VERSION.should == '0.0.1'
    end
  end
end