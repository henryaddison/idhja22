require 'configuration'
require 'idhja22/config/default'

require "idhja22/version"
require "idhja22/dataset"
require "idhja22/tree"
require "idhja22/bayes"

module Idhja22
  DEFAULT_PROBABILITY = 0.5
  TERMINATION_PROBABILITY = 0.95
  MIN_DATASET_SIZE = 20

  def self.config
    @config ||= Configuration.for('default')
  end
end
