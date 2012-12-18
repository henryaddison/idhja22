if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end
$: << File.dirname(__FILE__) + '/../lib'

require 'idhja22'
require 'ruby-debug'

Configuration.for('spec', Idhja22.config) {
  min_dataset_size 2
}

Idhja22.configure('spec')

RSpec.configure do |config|
  
end