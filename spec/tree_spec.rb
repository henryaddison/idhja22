require 'spec_helper'

describe Idhja22::Tree do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  it 'should make a tree' do
    tree = Idhja22::Tree.train(@ds)
  end
end