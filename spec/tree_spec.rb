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
        ds = Idhja22::Dataset.new([Idhja22::Dataset::Datum.new(['high', '20-30', 'Vanilla', 'Y'], ['Confidence', 'Age group', 'Fav ice cream'] , 'Loves Reading')], ['Confidence', 'Age group', 'Fav ice cream'], 'Loves Reading')
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

  describe('#evaluate') do
    it 'should return the probabilty at the leaf of the tree' do
      tree = Idhja22::Tree.train(@ds)
      query = Idhja22::Dataset::Datum.new(['z','z','a','z','a'],['0', '1','2','3','4'],'C')
      tree.evaluate(query).should == 1.0
    end
  end

  describe '#validate' do
    before(:all) do
      @tree = Idhja22::Tree.train(@ds)
    end

    it 'should return the average probability that the tree gets the validation examples correct' do
      vps = [Idhja22::Dataset::Example.new(['z','z','a','z','a','Y'],['0', '1','2','3','4'],'C')]
      vps << Idhja22::Dataset::Example.new(['z','z','a','z','a','N'],['0', '1','2','3','4'],'C')
      @tree.validate(Idhja22::Dataset.new(vps, ['0', '1','2','3','4'],'C')).should == 0.5
    end

    context 'against a data point with an unrecognised attribute value' do
      before(:all) do
        validation_point = Idhja22::Dataset::Example.new(['z','z','o','z','a','Y'],['0', '1','2','3','4'],'C')
        @vps = Idhja22::Dataset.new([validation_point], ['0', '1','2','3','4'],'C')
      end

      it 'should treat a validation example as one it will never get right' do
        @tree.validate(@vps).should == 0.0
      end
    end
  end

  describe '.train_and_validate' do
    it 'should return a tree and the validation result' do
      tree, value = Idhja22::Tree.train_and_validate(@ds)
      tree.is_a?(Idhja22::Tree).should be_true
      (0..1).include?(value).should be_true
    end
  end

  describe('.train_and_validate_from_csv') do
    it 'should make the same tree as the one from the dataset' do
      csv_tree, validation_value = Idhja22::Tree.train_and_validate_from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'), :"training-proportion" => 0.75)
      csv_tree.is_a?(Idhja22::Tree).should be_true
      (0..1).include?(validation_value).should be_true
    end
  end
end