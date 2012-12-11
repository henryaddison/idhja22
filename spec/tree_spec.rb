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
      Idhja22::Tree.train(@ds).get_rules.should == "if 2 == a and then chance of liking = 0.8\nelsif 2 == b and then chance of liking = 0.8"
    end
  end
end