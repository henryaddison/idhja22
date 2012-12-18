require 'configuration'
require 'idhja22/config/default'

require "idhja22/version"
require "idhja22/dataset"
require "idhja22/tree"
require "idhja22/bayes"

module Idhja22
  def self.default_config
    Configuration.for('default')
  end

  def self.configure(name)
    new_config = Configuration.for(name)
    @cached_config = new_config
  end

  def self.config
    @cached_config ||= default_config
  end

end
