require 'spec_helper'

describe Idhja22::Node do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  
end