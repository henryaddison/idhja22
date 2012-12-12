module Idhja22
  class Tree
    attr_accessor :root
    class << self
      def train(dataset)
        new(dataset, dataset.attribute_labels)
      end

      def train_from_csv(filename)
        ds = Dataset.from_csv(filename)
        train(ds)
      end

      def build_node(dataset, attributes_available, depth, parent_probability = nil)
        if(dataset.size < Idhja22::MIN_DATASET_SIZE)
          return Idhja22::LeafNode.new(probability_guess(parent_probability, depth), dataset.category_label)
        end

        #if successful termination - create and return a leaf node
        if(dataset.terminating? && depth > 0) # don't terminate without splitting the data at least once
          return Idhja22::LeafNode.new(dataset.probability, dataset.category_label)
        end

        #if we have no more attributes left to split the dataset on, then return a leafnode
        if(attributes_available.empty?)
          return Idhja22::LeafNode.new(dataset.probability, dataset.category_label)
        end

        data_split , best_attribute = best_attribute(dataset, attributes_available)

        node = Idhja22::DecisionNode.new(data_split, best_attribute, attributes_available-[best_attribute], depth, dataset.probability)

        return node
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

      def probability_guess(parent_probability, depth)
        return (parent_probability + (0.5-parent_probability)/2**depth)
      end
    end

    def initialize(dataset, attributes_available)
      raise Idhja22::Dataset::InsufficientData, "require at least #{Idhja22::MIN_DATASET_SIZE} data points, only have #{dataset.size} in data set provided" if(dataset.size < Idhja22::MIN_DATASET_SIZE)
      @root = self.class.build_node(dataset, attributes_available, 0)
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