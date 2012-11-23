require 'spec_helper'

describe Idhja22::Dataset do
  context 'initialization' do
    
    def check_labels(obj, exp_attr_labels, exp_cat_label)
      obj.attribute_labels.should == exp_attr_labels
      obj.category_label.should == exp_cat_label
    end

    describe 'from_csv' do
      before(:all) do
        @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'spec_data.csv'))
      end

      it 'should extract labels' do
        check_labels(@ds, ['Weather', 'Temperature', 'Wind'], 'Plays')
      end

      it 'should extract data' do
        @ds.data.length.should == 3
        @ds.data.collect(&:attributes).should == [['sunny', 'hot', 'light'], ['sunny', 'cold', 'medium'], ['raining', 'cold', 'high']]
        @ds.data.collect(&:category).should == ['Y','~','N']
      end
    end

    describe 'new' do
      before(:all) do
        @ds = Idhja22::Dataset.new([['Confidence', 'Age group', 'Weight', 'Loves Brand'],['high', '20-30', 'Tubby', 'Y']])
      end
      
      it 'should extract labels' do
        check_labels(@ds, ['Confidence', 'Age group', 'Weight'], 'Loves Brand')
      end

      it 'should extract data' do
        @ds.data.length.should == 1
        @ds.data.first.attributes.should == ['high', '20-30', 'Tubby']
        @ds.data.first.category.should == 'Y'
      end

    end
  end
end
