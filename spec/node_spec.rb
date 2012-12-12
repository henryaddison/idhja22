require 'spec_helper'

describe Idhja22::LeafNode do
  describe('.new') do
    it 'should store probability and category label' do
      l = Idhja22::LeafNode.new(0.75, 'label')
      l.probability.should == 0.75
      l.category_label.should == 'label'
    end
  end

  describe('#get_rules') do
    it 'should return the probability' do
      l = Idhja22::LeafNode.new(0.75, 'pudding')
      l.get_rules.should == ['then chance of pudding = 0.75']
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
      l.get_rules.should == ["3 == a and then chance of C = 0.75", "3 == b and then chance of C = 0.0"]
    end
  end
end