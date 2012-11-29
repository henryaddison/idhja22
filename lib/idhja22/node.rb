module Idhja22
  class Node

  end

  class DecisionNode < Node
    attr_reader :branches, :decision_attribute
    def initialize(data_split, decision_attribute, attributes_available)
      @decision_attribute = decision_attribute
      @branches = {}
      data_split.each do |value, dataset|
        @branches[value] = Tree.new(dataset, attributes_available)
      end
    end
  end

  class LeafNode < Node
    attr_reader :label
    def initialize(category)
      @label = category
    end
  end
end