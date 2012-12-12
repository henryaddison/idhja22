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

  describe(' == ') do
    let(:l1) { Idhja22::LeafNode.new(0.75, 'pudding') }
    let(:l2) { Idhja22::LeafNode.new(0.75, 'pudding') }
    let(:diff_l1) { Idhja22::LeafNode.new(0.7, 'pudding') }
    let(:diff_l2) { Idhja22::LeafNode.new(0.75, 'starter') }
    it 'should compare attributes' do
      l1.should == l2
      l1.should_not == diff_l1
      l1.should_not == diff_l2
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

  describe(' == ') do
    let(:dn1) { Idhja22::DecisionNode.new(@ds.split(2), '2', [], 0.75) }
    let(:dn2) { Idhja22::DecisionNode.new(@ds.split(2), '2', [], 0.75) }
    let(:diff_dn1) { Idhja22::DecisionNode.new(@ds.split(0), '2', [], 0.75) }
    let(:diff_dn2) { Idhja22::DecisionNode.new(@ds.split(3), '3', [], 0.75) }

    it 'should compare ' do
      dn1.should == dn2
      dn1.should_not == diff_dn1
      dn1.should_not == diff_dn2
    end
  end
end