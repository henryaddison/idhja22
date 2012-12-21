require 'spec_helper'

describe Idhja22 do 
  describe '.configure' do
    it 'should edit the default config' do
      Idhja22.configure do
        min_dataset_size 2
        new_setting 42
      end
      Idhja22.config.new_setting.should == 42
      Idhja22.config.min_dataset_size.should == 2
    end
  end
end