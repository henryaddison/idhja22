require 'spec_helper'

describe Idhja22::Bayes do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(File.dirname(__FILE__),'large_spec_data.csv'))
  end

  describe '.train' do
    it 'should train a classifier from a dataset' do
      classifier = Idhja22::Bayes.train @ds, %w{0}
      cond_probs = classifier.conditional_probabilities
      cond_probs.keys.should == ['0']
      cond_probs['0'].keys.should == ['a','b']
      cond_probs['0']['a']['Y'].should == 0.625
      cond_probs['0']['a']['N'].should == 0.375

      cond_probs['0']['b']['Y'].should == 0.5
      cond_probs['0']['b']['N'].should == 0.5

      prior_probs = classifier.prior_probabilities
      prior_probs['Y'].should == 0.6
      prior_probs['N'].should == 0.4
    end
  end

  describe '.calculate_conditional_probabilities' do
    it 'should calculate the conditional probabilities of P(Cat|attr_val) from dataset for given attribute labels' do
      cond_probs = Idhja22::Bayes.calculate_conditional_probabilities @ds, %w{0 2}
      cond_probs.keys.should == ['0', '2']
      cond_probs['0'].keys.should == ['a','b']
      cond_probs['2'].keys.should == ['a','b']

      cond_probs['0']['a']['Y'].should == 0.625
      cond_probs['0']['a']['N'].should == 0.375
      cond_probs['0']['b']['Y'].should == 0.5
      cond_probs['0']['b']['N'].should == 0.5

      cond_probs['2']['a']['Y'].should == 0.75
      cond_probs['2']['a']['N'].should == 0.25
      cond_probs['2']['b']['Y'].should == 0
      cond_probs['2']['b']['N'].should == 1.0
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
end