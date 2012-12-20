require "idhja22/dataset/errors"
require "idhja22/dataset/tree_methods"
require "idhja22/dataset/datum"
require 'csv'

module Idhja22
  class Dataset
    attr_reader :category_label, :attribute_labels, :data

    include Idhja22::Dataset::TreeMethods

    class << self
      def from_csv(filename)
        csv = CSV.read(filename)

        labels = csv.shift
        category_label = labels.pop
        attribute_labels = labels

        set = new([], attribute_labels, category_label)
        csv.each do |row|
          training_example = Example.new(row, attribute_labels, category_label)
          set << training_example
        end

        return set
      end
    end

    def initialize(data, attr_labels, category_label)
      @category_label = category_label
      raise NonUniqueAttributeLabels, "repeated attributes in #{attr_labels}" unless attr_labels == attr_labels.uniq
      @attribute_labels = attr_labels
      @data = data
    end

    def category_counts
      counts = Hash.new(0)
      split_data = partition_by_category
      split_data.each do |cat, d|
        counts[cat] = d.size
      end
      return counts
    end

    def size
      return data.size
    end

    def empty?
      return data.empty?
    end

    def probability
      category_counts['Y'].to_f/size.to_f
    end

    def split(training_proportion)
      shuffled_data = data.shuffle
      cutoff_point = (training_proportion.to_f*size).to_i

      training_data = shuffled_data[0...cutoff_point]
      validation_data = shuffled_data[cutoff_point...size]

      training_set = self.class.new(training_data, attribute_labels, category_label)
      validation_set = self.class.new(validation_data, attribute_labels, category_label)

      return training_set, validation_set
    end

    def <<(example)
      raise Idhja22::Dataset::Datum::UnknownCategoryLabel unless example.category_label == self.category_label
      raise Idhja22::Dataset::Datum::UnknownAttributeLabel unless example.attribute_labels == self.attribute_labels
      self.data << example
    end

    def partition_by_category
      output = Hash.new do |hash, key|
        hash[key] = self.class.new([], attribute_labels, category_label)
      end
      self.data.each do |d|
        output[d.category] << d
      end
      return output
    end
  end
end