require 'spec_helper'

describe Idhja22::Dataset do
  describe 'from_csv' do
    it 'should extract labels' do
      ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'spec_data.csv'))
      ds.attribute_labels.should == ['Weather', 'Temperature', 'Wind']
      ds.category_label.should == 'Plays'
    end

    it 'should extract data' do

    end
  end
end
