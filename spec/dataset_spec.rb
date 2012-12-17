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
        @ds.data.collect(&:category).should == ['Y', 'Y','N']
      end
    end

    describe 'new' do
      before(:all) do
        @ds = Idhja22::Dataset.new([Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla', 'Y'], ['Confidence', 'Age group', 'fav ice cream'] , 'Loves Reading')], ['Confidence', 'Age group', 'fav ice cream'], 'Loves Reading')
      end
      
      it 'should extract labels' do
        check_labels(@ds, ['Confidence', 'Age group', 'fav ice cream'], 'Loves Reading')
      end

      it 'should extract data' do
        @ds.data.length.should == 1
        @ds.data.first.attributes.should == ['high', '20-30', 'vanilla']
        @ds.data.first.category.should == 'Y'
      end

      context 'with repeated attribute labels' do
        it 'should throw an error' do
          expect do 
            Idhja22::Dataset.new([Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla', 'Y'], ['Confidence', 'Age group', 'Confidence'] , 'Loves Reading')], ['Confidence', 'Age group', 'Confidence'], 'Loves Reading')
          end.to raise_error(Idhja22::Dataset::NonUniqueAttributeLabels)
        end
      end
    end

    context 'ready made' do
      before(:all) do
        @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
      end

      describe '#partition' do
        it 'should split the data set based on the values of an given attribute index' do
          new_sets = @ds.partition('0')
          new_sets.length.should == 2
          new_sets.each do |value, dset|
            dset.data.collect { |d| d.attributes[0] }.uniq.should == [value]
          end
        end

        it 'should preserve the data other than splitting it' do
          new_sets = @ds.partition('3')
          new_sets.length.should == 3
          new_sets['a'].attribute_labels.should == @ds.attribute_labels
          new_sets['a'].category_label.should == @ds.category_label
          new_sets['a'].data.collect(&:to_a).should == [%w{a a a a a Y}, %w{b a a a a Y}, %w{a a a a a Y}, %w{a a a a a Y}, %w{a a a a a Y}, %w{a a a a b N}, %w{a a a a b N}]
        end


        it 'should produce one item when the values are all the same' do
          @ds.partition('1').length.should == 1
        end
      end

      describe 'category_counts' do
        it 'should count the number of entries in each category' do
          @ds.category_counts.should == {'Y' => 6, 'N' => 4}
        end
      end

      describe '#entropy' do
        it 'should calculate entropy of set' do
          @ds.entropy.should be_within(0.000001).of(0.970951)
        end

        context 'with little data' do
          it 'should return 1' do
            ds = Idhja22::Dataset.new([Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla', 'Y'], ['Confidence', 'Age group', 'fav ice cream'] , 'Loves Reading')], ['Confidence', 'Age group', 'fav ice cream'], 'Loves Reading')
            ds.entropy.should == 1.0
          end
        end

      end

      describe '#size' do
        it 'should calculate size of dataset' do
          @ds.size.should == 10
        end 
      end

      describe '#empty?' do
        it 'should calculate size of dataset' do
          @ds.empty?.should be_false
        end 
      end

      describe '#probability' do
        it 'should return probabilty category is Y' do
          @ds.probability.should be_within(0.0001).of(0.6)
        end
      end

      describe '#split' do
        it 'should split into a training and validation set according to the given proportion' do
          ts, vs = @ds.split(0.5)
          ts.size.should == 5
          vs.size.should == 5

          ts, vs = @ds.split(0.75)
          ts.size.should == 7
          vs.size.should == 3
        end
      end
    end
  end
end
