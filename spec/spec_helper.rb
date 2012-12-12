if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end
$: << File.dirname(__FILE__) + '/../lib'

require 'idhja22'
require 'ruby-debug'

module Idhja22
  MIN_DATASET_SIZE = 2
end



RSpec.configure do |config|
  
end