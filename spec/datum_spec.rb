require 'spec_helper'

describe Idhja22::Dataset::Datum do
  describe 'new' do
    before(:all) do
      @datum = Idhja22::Dataset::Datum.new(['high', '20-30', 'tubby','Y'])
    end

    it 'should extract attributes' do
      @datum.attributes.should == ['high', '20-30', 'tubby']
    end

    it 'should extract category' do
      @datum.category.should == 'Y'
    end
  end
end