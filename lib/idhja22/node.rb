module Idhja22
  class Node

  end

  class DecisionNode < Node
    attr_reader :branches, :decision_attribute
    def initialize(data_split, decision_attribute, attributes_available)
      @decision_attribute = decision_attribute
      @branches = {}
      data_split.each do |value, dataset|
        node = Tree.build_node(dataset, attributes_available)
        @branches[value] = node if node && !(node.is_a?(LeafNode) && node.label == '~') && !(node.is_a?(DecisionNode) && node.branches.empty?)
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