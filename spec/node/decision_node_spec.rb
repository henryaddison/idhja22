require 'spec_helper'

describe Idhja22::DecisionNode do
  before(:all) do
    @ds = Idhja22::Dataset.from_csv(File.join(data_dir,'large_spec_data.csv'))
  end

  describe('#get_rules') do
    it 'should return a list of rules' do
      l = Idhja22::DecisionNode.new(@ds.partition('2'), '3', [], 0, 0.75)
      l.get_rules.should == ["3 == a and then chance of C = 0.75", "3 == b and then chance of C = 0.0"]
    end
  end

  describe(' == ') do
    let(:dn1) { Idhja22::DecisionNode.new(@ds.partition('2'), '2', [], 0, 0.75) }
    let(:dn2) { Idhja22::DecisionNode.new(@ds.partition('2'), '2', [], 0, 0.75) }
    let(:diff_dn1) { Idhja22::DecisionNode.new(@ds.partition('0'), '2', [], 0, 0.75) }
    let(:diff_dn2) { Idhja22::DecisionNode.new(@ds.partition('3'), '3', [], 0, 0.75) }

    it 'should compare ' do
      dn1.should == dn2
      dn1.should_not == diff_dn1
      dn1.should_not == diff_dn2
    end
  end

  describe 'evaluate' do
    let(:dn) { Idhja22::DecisionNode.new(@ds.partition('2'), '3', [], 0, 0.75) }
    it 'should follow node to probability' do
      query = Idhja22::Dataset::Datum.new(['a', 'a'], ['3', '4'], 'C')
      dn.evaluate(query).should == 0.75

      query = Idhja22::Dataset::Datum.new(['b', 'a'], ['3', '4'], 'C')
      dn.evaluate(query).should == 0.0
    end

    context 'mismatching attribute label' do
      it 'should raise an error' do
        query = Idhja22::Dataset::Datum.new(['b', 'a'], ['1', '2'], 'C')
        expect {dn.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeLabel)
      end
    end

    context 'unknown attribute value' do
      it 'should raise an error' do
        query = Idhja22::Dataset::Datum.new(['c', 'a'], ['3', '4'], 'C')
        expect {dn.evaluate(query)}.to raise_error(Idhja22::Dataset::Datum::UnknownAttributeValue)
      end
    end
  end
end