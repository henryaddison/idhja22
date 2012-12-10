module Idhja22
  class Tree
    attr_accessor :root
    class << self
      def train(dataset)
        new(dataset, dataset.attribute_labels)
      end

      def build_node(dataset, attributes_available)
        if(dataset.size < 10)
          return nil
        end

        #if successful termination - create and return a leaf node
        if(dataset.terminating?)
          return Idhja22::LeafNode.new(dataset.probability)
        end

        #if we have no more attributes left to split the dataset on, then return a leafnode
        if(attributes_available.empty?)
          return Idhja22::LeafNode.new(dataset.probability)
        end

        data_split , best_attribute = best_attribute(dataset, attributes_available)

        return Idhja22::DecisionNode.new(data_split, best_attribute, attributes_available-[best_attribute])
      end

      private
      def best_attribute(dataset, attributes_available)
        data_split = best_attribute = nil
        igain = - Float::INFINITY

        attributes_available.each do |attr|
          possible_split = dataset.split(dataset.attribute_labels.index(attr))
          possible_igain = dataset.entropy
          possible_split.each do |value, ds|
            possible_igain -= (ds.size.to_f/dataset.size.to_f)*ds.entropy
          end
          if(possible_igain > igain)
            igain = possible_igain
            data_split = possible_split
            best_attribute = attr
          end
        end
        return data_split, best_attribute
      end
    end

    def initialize(dataset, attributes_available)
      @root = self.class.build_node(dataset, attributes_available)
    end

    def get_rules
      output = "if "
      rules = root.get_rules
      "if " + rules.join("\nelsif ")
    end
  end
end