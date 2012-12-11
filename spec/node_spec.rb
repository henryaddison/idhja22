require 'spec_helper'

describe Idhja22::Node do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

end

describe Idhja22::LeafNode do
  describe('#get_rules') do
    it 'should return the probability' do
      l = Idhja22::LeafNode.new(0.75)
      l.get_rules.should == ['then chance of liking = 0.75']
    end
  end
  
end

describe Idhja22::DecisionNode do
  describe('#get_rules') do
    
  end
end