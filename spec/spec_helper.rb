if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end
$: << File.dirname(__FILE__) + '/../lib'

require 'idhja22'
require 'ruby-debug'

Idhja22.configure do
  min_dataset_size 2
end

def data_dir
  File.dirname(__FILE__) + '/data/'
end

RSpec.configure do |config|
  
end