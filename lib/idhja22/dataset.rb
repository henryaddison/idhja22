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

        data = []
        csv.each do |row|
          training_example = Example.new(row, attribute_labels, category_label)
          data << training_example
        end

        new(data, attribute_labels, category_label)
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
      data.each do |d|
        counts[d.category]+=1
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

  end
end