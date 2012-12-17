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
      query = Idhja22::Dataset::Query.new(['high', 'gusty'], ['temperature', 'windy'], 'pudding')
      leaf.evaluate(query).should == 0.6
    end

    context 'mismatching category labels' do
      it 'should raise error' do
        query = Idhja22::Dataset::Query.new(['high', 'gusty'], ['temperature', 'windy'], 'tennis')
        expect {leaf.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownCategoryLabel)
      end
    end
  end
end

describe Idhja22::DecisionNode do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  describe('#get_rules') do
    it 'should return a list of rules' do
      l = Idhja22::DecisionNode.new(@ds.partition('2'), '3', [], 0, 0.75)
      l.get_rules.should == ["3 == a and then chance of C = 0.75", "3 == b and then chance of C = 0.0"]
    end
  end

  describe(' == ') do
    let(:dn1) { Idhja22::DecisionNode.new(@ds.partition('2'), '2', [], 0, 0.75) }
    let(:dn2) { Idhja22::DecisionNode.new(@ds.partition('2'), '2', [], 0, 0.75) }
    let(:diff_dn1) { Idhja22::DecisionNode.new(@ds.partition('0'), '2', [], 0, 0.75) }
    let(:diff_dn2) { Idhja22::DecisionNode.new(@ds.partition('3'), '3', [], 0, 0.75) }

    it 'should compare ' do
      dn1.should == dn2
      dn1.should_not == diff_dn1
      dn1.should_not == diff_dn2
    end
  end

  describe 'evaluate' do
    let(:dn) { Idhja22::DecisionNode.new(@ds.partition('2'), '3', [], 0, 0.75) }
    it 'should follow node to probability' do
      query = Idhja22::Dataset::Query.new(['a', 'a'], ['3', '4'], 'C')
      dn.evaluate(query).should == 0.75

      query = Idhja22::Dataset::Query.new(['b', 'a'], ['3', '4'], 'C')
      dn.evaluate(query).should == 0.0
    end

    context 'mismatching attribute label' do
      it 'should raise an error' do
        query = Idhja22::Dataset::Query.new(['b', 'a'], ['1', '2'], 'C')
        expect {dn.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeLabel)
      end
    end

    context 'unknown attribute value' do
      it 'should raise an error' do
        query = Idhja22::Dataset::Query.new(['c', 'a'], ['3', '4'], 'C')
        expect {dn.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeValue)
      end
    end
  end
end