require 'spec_helper'

describe Idhja22::DecisionNode do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(data_dir,'large_spec_data.csv'))
    @simple_decision_node = Idhja22::DecisionNode.new('3')

    l1 = Idhja22::LeafNode.new(0.75, 'C')
    l2 = Idhja22::LeafNode.new(0.0, 'C')

    @simple_decision_node.add_branch('a', l1)
    @simple_decision_node.add_branch('b', l2)
  end

  describe('#get_rules') do
    it 'should return a list of rules' do
      @simple_decision_node.get_rules.should == ["3 == a and then chance of C = 0.75", "3 == b and then chance of C = 0.0"]
    end
  end

  describe '#outputs' do
    it 'should return a list of terminating values' do
      @simple_decision_node.outputs.should == [0.75, 0]
    end

    context 'a branch without a terminating leaf node' do
      it 'should throw an error' do
        decision_node = Idhja22::DecisionNode.new('a')
        decision_node.add_branch('1', Idhja22::LeafNode.new(0.75, 'C'))
        decision_node.add_branch('2', Idhja22::DecisionNode.new('b'))

        expect { decision_node.outputs }.to raise_error(Idhja22::IncompleteTree)
      end
    end
  end

  describe(' == ') do
    it 'should return false with different decision attributes' do
      dn = Idhja22::DecisionNode.new('2')
      diff_dn = Idhja22::DecisionNode.new('3')
      dn.should_not == diff_dn
    end

    it 'should return false with different branches' do
      dn1 = Idhja22::DecisionNode.new('2')
      diff_dn = Idhja22::DecisionNode.new('2')

      leaf = Idhja22::LeafNode.new(0.75, 'C')
      dn1.add_branch('value', leaf)

      dn1.should_not == diff_dn
    end

    it 'should return true if decision node and branches match' do
      dn1 = Idhja22::DecisionNode.new('2')
      dn2 = Idhja22::DecisionNode.new('2')

      leaf = Idhja22::LeafNode.new(0.75, 'C')
      dn1.add_branch('value', leaf)
      dn2.add_branch('value', leaf)

      dn1.should == dn2
    end
  end

  describe 'evaluate' do
    it 'should follow node to probability' do
      query = Idhja22::Dataset::Datum.new(['a', 'a'], ['3', '4'], 'C')
      @simple_decision_node.evaluate(query).should == 0.75

      query = Idhja22::Dataset::Datum.new(['b', 'a'], ['3', '4'], 'C')
      @simple_decision_node.evaluate(query).should == 0.0
    end

    context 'mismatching attribute label' do
      it 'should raise an error' do
        query = Idhja22::Dataset::Datum.new(['b', 'a'], ['1', '2'], 'C')
        expect {@simple_decision_node.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeLabel)
      end
    end

    context 'unknown attribute value' do
      it 'should raise an error' do
        query = Idhja22::Dataset::Datum.new(['c', 'a'], ['3', '4'], 'C')
        expect {@simple_decision_node.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeValue)
      end
    end
  end

  describe('.build') do
    it 'should build a decision node based on the provided data' do
      node = Idhja22::DecisionNode.build(@ds, @ds.attribute_labels, 0)
      node.decision_attribute.should == "2"
      node.branches.keys.should == ['a','b']
    end
  end

  describe '#add_branch' do
    it 'should add a branch for the given attribute value' do
      node = Idhja22::DecisionNode.new 'attribute_name'
      branch_node = Idhja22::DecisionNode.new 'other_name'
      node.add_branch('value', branch_node)
      node.branches.keys.should == ['value']
      node.branches['value'].should == branch_node
    end
  end
end