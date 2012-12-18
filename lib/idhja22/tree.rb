require "idhja22/tree/node"

module Idhja22
  # The main entry class for a training, viewing and evaluating a decision tree.
  class Tree < BinaryClassifier
    attr_accessor :root
    class << self
    end

    def train(dataset, attributes_available)
      raise Idhja22::Dataset::InsufficientData, "require at least #{Idhja22.config.min_dataset_size} data points, only have #{dataset.size} in data set provided" if(dataset.size < Idhja22.config.min_dataset_size)
      @root = Node.build_node(dataset, attributes_available, 0)
      return self
    end

    def get_rules
      rules = root.get_rules
      "if " + rules.join("\nelsif ")
    end

    def ==(other)
      return self.root == other.root
    end

    def evaluate query
      @root.evaluate(query)
    end
  end
end