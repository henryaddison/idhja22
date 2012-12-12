require 'spec_helper'

describe Idhja22::Tree do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  
  describe('.train') do
    it 'should make a tree' do
      tree = Idhja22::Tree.train(@ds)
    end
  end

  describe('#get_rules') do
    it 'should list the rules of the tree' do
      Idhja22::Tree.train(@ds).get_rules.should == "if 2 == a and 4 == a and then chance of C = 1.0\nelsif 2 == a and 4 == b and then chance of C = 0.0\nelsif 2 == b and then chance of C = 0.0"
    end
  end
end