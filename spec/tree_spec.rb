require 'spec_helper'

describe Idhja22::Tree do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  
  describe('.train') do
    it 'should make a tree' do
      tree = Idhja22::Tree.train(@ds)
    end

    context 'with insufficient data' do
      it 'should throw exception' do
        ds = Idhja22::Dataset.new([Idhja22::Dataset::Datum.new(['high', '20-30', 'Tubby', 'Y'], ['Confidence', 'Age group', 'Weight'] , 'Loves Brand')], ['Confidence', 'Age group', 'Weight'], 'Loves Brand')
        expect { Idhja22::Tree.train(ds) }.to raise_error(Idhja22::Dataset::InsufficientData)
      end
    end
  end

  describe('#get_rules') do
    it 'should list the rules of the tree' do
      Idhja22::Tree.train(@ds).get_rules.should == "if 2 == a and 4 == a and then chance of C = 1.0\nelsif 2 == a and 4 == b and then chance of C = 0.0\nelsif 2 == b and then chance of C = 0.0"
    end
  end

  describe(' == ') do
    it 'should compare root nodes' do
      tree1 = Idhja22::Tree.train(@ds)
      tree2 = Idhja22::Tree.train(@ds)
      diff_ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'another_large_spec_data.csv'))
      diff_tree = Idhja22::Tree.train(diff_ds)
      tree1.should == tree2
      tree1.should_not == diff_tree
    end
  end

  describe('.train_from_csv') do
    it 'should make the same tree as the one from the dataset' do
      tree = Idhja22::Tree.train(@ds)
      csv_tree = Idhja22::Tree.train_from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
      tree.should == csv_tree
    end
  end
end