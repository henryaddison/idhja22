require 'configuration'
require 'idhja22/config/default'

require "idhja22/version"
require "idhja22/dataset"
require "idhja22/binary_classifier"
require "idhja22/tree"
require "idhja22/bayes"

module Idhja22
  def self.configure(&block)
    @cached_config = Configuration.for('default', &block)
  end

  def self.config
    @cached_config ||= Configuration.for('default')
  end
end
