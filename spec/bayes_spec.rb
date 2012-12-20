require 'spec_helper'

describe Idhja22::Bayes do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(data_dir,'large_spec_data.csv'))
  end

  describe '.train' do
    it 'should train a classifier from a dataset' do
      classifier = Idhja22::Bayes.train @ds, :attributes => %w{0}
      cond_probs = classifier.conditional_probabilities
      cond_probs.keys.should == ['0']
      
      cond_probs['0'].keys.should == ['Y', 'N']

      cond_probs['0']['Y']['a'].should == 5.0/6.0
      cond_probs['0']['N']['a'].should == 0.75

      cond_probs['0']['Y']['b'].should == 1.0/6.0
      cond_probs['0']['N']['b'].should == 0.25

      prior_probs = classifier.prior_probabilities
      prior_probs['Y'].should == 0.6
      prior_probs['N'].should == 0.4
    end
  end

  describe '.calculate_conditional_probabilities' do
    it 'should calculate the conditional probabilities of P(Cat|attr_val) from dataset for given attribute labels' do
      cond_probs = Idhja22::Bayes.calculate_conditional_probabilities @ds, %w{0 2}
      cond_probs.keys.should == ['0', '2']
      cond_probs['0'].keys.should == ['Y','N']
      cond_probs['2'].keys.should == ['Y','N']

      cond_probs['0']['Y']['a'].should == 5.0/6.0
      cond_probs['0']['N']['a'].should == 0.75
      cond_probs['0']['Y']['b'].should == 1.0/6.0
      cond_probs['0']['N']['b'].should == 0.25

      cond_probs['2']['Y']['a'].should == 1.0
      cond_probs['2']['N']['a'].should == 0.5
      cond_probs['2']['Y']['b'].should == 0
      cond_probs['2']['N']['b'].should == 0.5
    end
  end

  describe '.calculate_priors' do
    it 'should calculate the prior probabilities' do
      prior_probs = Idhja22::Bayes.calculate_priors @ds
      prior_probs['Y'].should == 0.6
      prior_probs['N'].should == 0.4
    end

    context 'all single category' do
      it 'should return 0 for other categories' do
        uniform_ds = Idhja22::Dataset.new([Idhja22::Dataset::Example.new(['high', '20-30', 'vanilla', 'Y'], ['Confidence', 'Age group', 'fav ice cream'] , 'Loves Reading')], ['Confidence', 'Age group', 'fav ice cream'], 'Loves Reading')
        prior_probs = Idhja22::Bayes.calculate_priors uniform_ds
        prior_probs['Y'].should == 1.0
        prior_probs['N'].should == 0
      end
    end
  end

  describe '#evaluate' do
    before(:all) do
      @bayes = Idhja22::Bayes.new
      @bayes.conditional_probabilities = {
        'age' => {
          'Y' => {'young' => 0.98, 'old' => 0.02},
          'N' => {'young' => 0.98, 'old' => 0.02}
          
        }, 
        'confidence' => {
          'Y' => {'high' => 0.6, 'medium' => 0.3, 'low' => 0.1},
          'N' => {'high' => 0.8, 'medium' => 0.15, 'low' => 0.05}
        }, 
        'fav ice cream' => {
          'Y' => {'vanilla' => 0.75, 'strawberry' => 0.25},
          'N' => {'vanilla' => 0.5, 'strawberry' => 0.6}
        } 
      }
      @bayes.prior_probabilities = {'Y' => 0.75, 'N' => 0.25}
    end

    context 'Y likely' do
      it 'should return probability of being Y' do
        query = Idhja22::Dataset::Datum.new(['high', 'young', 'vanilla', 'cheddar'], ['confidence', 'age', 'fav ice cream', 'fav cheese'], 'Loves Reading')
        @bayes.evaluate(query).should be_within(0.00001).of(0.77143)
      end
    end

    context 'N likely' do
      it 'should return probability of being Y' do
        query = Idhja22::Dataset::Datum.new(['high', 'young', 'strawberry', 'cheddar'], ['confidence', 'age', 'fav ice cream', 'fav cheese'], 'Loves Reading')
        @bayes.evaluate(query).should be_within(0.00001).of(0.48387)
      end
    end

    context 'unrecognised attribute value' do
      it 'should throw an error' do
        query = Idhja22::Dataset::Datum.new(['high', 'young', 'chocolate', 'cheddar'], ['confidence', 'age', 'fav ice cream', 'fav cheese'], 'Loves Reading')
        expect { @bayes.evaluate(query) }.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeValue)
      end
    end
  end

  describe '#validate' do
    before(:all) do
      @bayes = Idhja22::Bayes.train(@ds)
    end

    it 'should return the average probability that the tree gets the validation examples correct' do
      vds = Idhja22::Dataset.new([], ['0', '1','2','3','4'],'C')
      vds << Idhja22::Dataset::Example.new(['a','a','a','a','a','Y'],['0', '1','2','3','4'],'C')
      vds << Idhja22::Dataset::Example.new(['a','a','a','a','a','N'],['0', '1','2','3','4'],'C')
      @bayes.validate(vds).should == 0.5
    end
  end
end