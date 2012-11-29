module Idhja22
  class Tree
    attr_reader :root
    class << self
      def train(dataset)
        new(dataset, dataset.attribute_labels)
      end
    end

    def initialize(dataset, attributes_available)
      if(dataset.empty?)
        @root = nil
        return
      end

      #if successful termination - create and return a leaf node
      if(dataset.data.collect(&:category).uniq.length == 1)
        @root = Idhja22::LeafNode.new(dataset.data.first.category)
        return
      end

      if(attributes_available.empty?)
        @root = nil
        return
      end

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
      @root = Idhja22::DecisionNode.new(data_split, best_attribute, attributes_available-[best_attribute])
    end
  end
end