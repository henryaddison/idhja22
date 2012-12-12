require 'spec_helper'

describe Idhja22::Dataset::Example do
  before(:all) do
    @datum = Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla','Y'], ['confidence', 'age', 'fav ice cream'], 'likes')
  end
  
  describe 'new' do
    it 'should extract attributes' do
      @datum.attributes.should == ['high', '20-30', 'vanilla']
      @datum.attribute_labels.should == ['confidence', 'age', 'fav ice cream']
    end

    it 'should extract category' do
      @datum.category.should == 'Y'
      @datum.category_label.should == 'likes'
    end

    context 'with non-unique attribute labels' do
      it 'should throw an exception' do
        expect do
          Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla','Y'], ['confidence', 'age', 'age'], 'likes')
        end.to raise_error(Idhja22::Dataset::NonUniqueAttributeLabels)
      end
    end

    context 'unexpected label' do
      it 'should raise an exception' do
        expect do
          Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla','H'], ['confidence', 'age', 'fav ice cream'], 'likes')
        end.to raise_error(Idhja22::Dataset::Example::UnknownCategoryValue)
      end
    end
  end

  describe 'to_a' do
    it 'should list the data in an array format' do
      @datum.to_a.should == ['high', '20-30', 'vanilla','Y']
    end
  end

  describe '[]' do
    context 'known attribute' do
      it 'should map attribute label to value' do
        @datum['age'].should == '20-30'
      end
    end

    context 'unknown attribute' do
      it 'should throw an exception' do
        expect do
          @datum['madeup']
        end.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeLabel)
      end
    end


  end
end