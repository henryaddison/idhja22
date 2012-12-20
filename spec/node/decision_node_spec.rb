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

  describe '#leaves' do
    it 'should return a list of terminating values' do
      @simple_decision_node.leaves.should == [Idhja22::LeafNode.new(0.75, 'C'), Idhja22::LeafNode.new(0.0, 'C')]
    end

    context 'a branch without a terminating leaf node' do
      it 'should throw an error' do
        decision_node = Idhja22::DecisionNode.new('a')
        decision_node.add_branch('1', Idhja22::LeafNode.new(0.75, 'C'))
        decision_node.add_branch('2', Idhja22::DecisionNode.new('b'))

        expect { decision_node.leaves }.to raise_error(Idhja22::IncompleteTree)
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

  describe 'category_label' do
    it 'should return the category_label from the leaves' do
      @simple_decision_node.category_label.should == 'C'
    end

    context 'incomplete node' do
      it 'should throw an error' do
        dn = Idhja22::DecisionNode.new('a')
        expect { dn.category_label }.to raise_error(Idhja22::IncompleteTree)
      end
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

    it 'should cleanup matching tails' do
      ds = Idhja22::Dataset.from_csv(File.join(data_dir,'evenly_split.csv'))
      node = Idhja22::DecisionNode.build(ds, ds.attribute_labels, 0)
      node.get_rules.should == ['1 == a and then chance of C = 0.5', '1 == b and then chance of C = 0.5']
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

  describe '#cleanup_children!' do
    context 'with matching output at level below' do
      before(:all) do
        @dn = Idhja22::DecisionNode.new('a')
        @dn_below = Idhja22::DecisionNode.new('b')
        @dn_below.add_branch('1', Idhja22::LeafNode.new(0.505, 'Category'))
        @dn_below.add_branch('2', Idhja22::LeafNode.new(0.50, 'Category'))
        @dn.add_branch('1', @dn_below)
      end
      it 'should merge any subnodes with same output into a single leafnode' do
        @dn.cleanup_children!
        @dn.branches['1'].should == Idhja22::LeafNode.new(0.505, 'Category')
      end
    end

    context 'with matching output at two levels below' do
      before(:all) do
        @dn = Idhja22::DecisionNode.new('a')
        @dn_1_below = Idhja22::DecisionNode.new('b')
        @dn.add_branch('1', @dn_1_below)

        @dn_2_below = Idhja22::DecisionNode.new('c')
        @dn_1_below.add_branch('1', @dn_2_below)

        @dn_2_below.add_branch('1', Idhja22::LeafNode.new(0.50, 'Category'))
        @dn_2_below.add_branch('2', Idhja22::LeafNode.new(0.50, 'Category'))
      end

      it 'should merge nodes recusively' do
        @dn.cleanup_children!
        @dn.branches['1'].should == Idhja22::LeafNode.new(0.50, 'Category')
      end
    end

    context 'with diverging branches that match internally' do
      before(:all) do
        @dn = Idhja22::DecisionNode.new('a')

        dn_1_below = Idhja22::DecisionNode.new('b')
        @dn.add_branch('1', dn_1_below)

        dn_2_below = Idhja22::DecisionNode.new('c')
        dn_1_below.add_branch('1', dn_2_below)

        dn_2_below.add_branch('1', Idhja22::LeafNode.new(0.50, 'Category'))
        dn_2_below.add_branch('2', Idhja22::LeafNode.new(0.50, 'Category'))

        dn_2_below = Idhja22::DecisionNode.new('d')
        dn_1_below.add_branch('2', dn_2_below)

        dn_2_below.add_branch('1', Idhja22::LeafNode.new(0.70, 'Category'))
        dn_2_below.add_branch('2', Idhja22::LeafNode.new(0.70, 'Category'))
      end

      it 'should merge nodes recusively' do
        @dn.cleanup_children!
        @dn.branches['1'].branches['1'].should == Idhja22::LeafNode.new(0.50, 'Category')
        @dn.branches['1'].branches['2'].should == Idhja22::LeafNode.new(0.70, 'Category')
      end
    end

    context 'without matching output' do
      before(:all) do
        @dn = Idhja22::DecisionNode.new('a')
        @dn_below = Idhja22::DecisionNode.new('b')
        @dn_below.add_branch('1', Idhja22::LeafNode.new(0.2, 'Category'))
        @dn_below.add_branch('2', Idhja22::LeafNode.new(0.70, 'Category'))
        @dn.add_branch('1', @dn_below)
      end

      it 'should do nothing' do
        saved_rules = @dn.get_rules
        @dn.cleanup_children!
        @dn.get_rules.should == saved_rules
      end
    end
  end
end