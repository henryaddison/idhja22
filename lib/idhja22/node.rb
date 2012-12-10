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
        @branches[value] = node if node && !(node.is_a?(DecisionNode) && node.branches.empty?)
      end
    end

    def get_rules
      rules = []
      branches.each do |v,n|
        current_rule = "#{decision_attribute} == #{v}"
        sub_rules = n.get_rules
        sub_rules.each do |r|
          rules << "#{current_rule} and #{r}"
        end
      end

      return rules
    end
  end

  class LeafNode < Node
    attr_reader :probabilty
    def initialize(probabilty)
      @probabilty = probabilty
    end

    def get_rules
      ["then chance of liking = #{probabilty}"]
    end
  end
end