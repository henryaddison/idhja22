module Idhja22
  class Node
    def ==(other)
      return self.class == other.class
    end
  end

  class DecisionNode < Node
    attr_reader :branches, :decision_attribute
    def initialize(data_split, decision_attribute, attributes_available, depth, parent_probability)
      @decision_attribute = decision_attribute
      @branches = {}
      data_split.each do |value, dataset|
        node = Tree.build_node(dataset, attributes_available, depth+1, parent_probability)
        if(node.is_a?(DecisionNode) && node.branches.values.all? { |n| n.is_a?(LeafNode) })
          probs = node.branches.values.collect(&:probability)
          if(probs.max - probs.min < 0.01)
            node = LeafNode.new(probs.max, dataset.category_label)
          end
        end
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

    def ==(other)
      return false unless super
      return false unless self.decision_attribute == other.decision_attribute
      return false unless self.branches.length == other.branches.length
      self.branches.each do |attr_value, node|
        return false unless other.branches.has_key?(attr_value)
        return false unless node == other.branches[attr_value]
      end
      return true
    end

    def evaluate(query)
      queried_value = query[self.decision_attribute]
      branch = self.branches[queried_value]
      raise Idhja22::Dataset::Datum::UnknownAttributeValue, "when looking at attribute labelled #{self.decision_attribute} could not find branch for value #{queried_value}" if branch.nil?
      branch.evaluate(query)
    end
  end

  class LeafNode < Node
    attr_reader :probability, :category_label
    def initialize(probability, category_label)
      @probability = probability
      @category_label = category_label
    end

    def get_rules
      ["then chance of #{category_label} = #{probability.round(2)}"]
    end

    def ==(other)
      return super && self.probability == other.probability && self.category_label == other.category_label
    end

    def evaluate(query)
      raise Idhja22::Dataset::Datum::UnknownCategoryLabel, "expected category label for query is #{query.category_label} but node is using #{self.category_label}" unless query.category_label == self.category_label
      return probability
    end
  end
end