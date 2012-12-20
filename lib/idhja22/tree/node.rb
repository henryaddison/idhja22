module Idhja22
  class Node
    class << self
      def build_node(dataset, attributes_available, depth, parent_probability = nil)
        if(dataset.size < Idhja22.config.min_dataset_size)
          return Idhja22::LeafNode.new(probability_guess(parent_probability, depth), dataset.category_label)
        end

        #if successful termination - create and return a leaf node
        if(dataset.terminating? && depth > 0) # don't terminate without splitting the data at least once
          return Idhja22::LeafNode.new(dataset.probability, dataset.category_label)
        end

        if(depth >= 3) # don't let trees get too long
          return Idhja22::LeafNode.new(dataset.probability, dataset.category_label)
        end

        #if we have no more attributes left to split the dataset on, then return a leafnode
        if(attributes_available.empty?)
          return Idhja22::LeafNode.new(dataset.probability, dataset.category_label)
        end

        node = DecisionNode.build(dataset, attributes_available, depth)

        return node
      end

      private
      def best_attribute(dataset, attributes_available)
        data_split = best_attribute = nil
        igain = - Float::INFINITY

        attributes_available.each do |attr_label|
          possible_split = dataset.partition(attr_label)
          possible_igain = dataset.entropy
          possible_split.each do |value, ds|
            possible_igain -= (ds.size.to_f/dataset.size.to_f)*ds.entropy
          end
          if(possible_igain > igain)
            igain = possible_igain
            data_split = possible_split
            best_attribute = attr_label
          end
        end
        return data_split, best_attribute
      end

      def probability_guess(parent_probability, depth)
        return (parent_probability + (Idhja22.config.default_probability-parent_probability)/2**depth)
      end
    end

    def ==(other)
      return self.class == other.class
    end
  end

  class DecisionNode < Node
    attr_reader :branches, :decision_attribute

    class << self
      def build(dataset, attributes_available, depth)
        data_split, best_attribute = best_attribute(dataset, attributes_available)

        output_node = new(best_attribute)

        data_split.each do |value, dataset|
          node = Node.build_node(dataset, attributes_available-[best_attribute], depth+1, dataset.probability)
          
          output_node.add_branch(value, node) if node && !(node.is_a?(DecisionNode) && node.branches.empty?)
        end

        return output_node
      end
    end

    def initialize(decision_attribute)
      @decision_attribute = decision_attribute
      @branches = {}
    end

    def add_branch(attr_value, node)
      @branches[attr_value] = node
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

    def cleanup_children!
      branches.each do |attr, child_node|
        leaves = child_node.leaves
        probs = leaves.collect(&:probability)
        if(probs.max - probs.min < Idhja22.config.probability_delta)
          new_node = LeafNode.new(probs.max, leaves.first.category_label)
          add_branch(attr, new_node)
        end
      end
    end

    def leaves
      raise Idhja22::IncompleteTree, "decision node with no branches" if branches.empty?
      branches.values.flat_map do |child_node|
        child_node.leaves
      end
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

    def leaves
      return [self]
    end
  end
end