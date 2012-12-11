require 'spec_helper'

describe Idhja22::LeafNode do
  describe('#get_rules') do
    it 'should return the probability' do
      l = Idhja22::LeafNode.new(0.75)
      l.get_rules.should == ['then chance of liking = 0.75']
    end
  end
end

describe Idhja22::DecisionNode do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  describe('#get_rules') do
    it 'should return a list of rules' do
      l = Idhja22::DecisionNode.new(@ds.split(2), '3', [], 0.75)
      l.get_rules.should == ["3 == a and then chance of liking = 0.75", "3 == b and then chance of liking = 0.75"]
    end
  end
end