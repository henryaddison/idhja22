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

  describe 'evaluate' do
    let(:leaf) { Idhja22::LeafNode.new(0.6, 'pudding') }

    it 'should return probability' do
      query = Idhja22::Dataset::Datum.new(['high', 'gusty'], ['temperature', 'windy'], 'pudding')
      leaf.evaluate(query).should == 0.6
    end

    context 'mismatching category labels' do
      it 'should raise error' do
        query = Idhja22::Dataset::Datum.new(['high', 'gusty'], ['temperature', 'windy'], 'tennis')
        expect {leaf.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownCategoryLabel)
      end
    end
  end

  describe '#outputs' do
    it 'should return the associated probability' do
      leaf = Idhja22::LeafNode.new(0.6, 'pudding')
      leaf.outputs.should == [0.6]
    end
  end
end