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
      if(category = terminating?(dataset))
        @root = Idhja22::LeafNode.new(category)
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

    private
    
    def terminating?(dataset)
      category_count = dataset.category_counts
      if category_count.size == 1
        return category_count.values.first
      end

      certain_categories = category_count.values - ['~']
      if(certain_categories.size == 1)
        certain_prop = category_count[certain_categories.first].to_f/(category_count[certain_categories.first] + category_count['~'])
        if certain_prop > 0.75
          return certain_categories.first
        end
      end

      return false
    end
  end
end