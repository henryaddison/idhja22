require 'csv'
module Idhja22
  class Dataset
    attr_reader :category_label, :attribute_labels, :data

    class Datum
      attr_reader :category, :attributes
      def initialize(row)
        @category = row.pop
        @attributes = row
      end

      def to_a
        attributes+[category]
      end
    end

    class << self
      def from_csv(filename)
        csv = CSV.read(filename)

        labels = csv.shift
        category_label = labels.pop
        attribute_labels = labels

        data = []
        csv.each do |row|
          data << Datum.new(row)
        end

        new(data, attribute_labels, category_label)
      end
    end

    def initialize(data, attr_labels, category_label)
      @category_label = category_label
      @attribute_labels = attr_labels
      @data = data
    end

    def split(attr_index)
      groups = Hash.new([])
      data.each do |datum|
        groups[datum.attributes[attr_index]] += [datum]
      end
      output = Hash.new
      groups.each do |value, data|
        output[value] = Dataset.new(data, attribute_labels, category_label)
      end
      return output
    end

    def entropy
      total = data.length
      entropy = 0
      category_counts.values.inject(0) { |ent, count|  prop = count.to_f/total.to_f; ent-prop*Math.log(prop,2)  }
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

    def best_guess
      cc = category_counts
      best_guesses = []
      count = -Float::INFINITY
      cc.each do |cat, value|
        if value > count
          count = value
          best_guesses = [cat]
        elsif value == count
          best_guesses << cat
        end
      end
      if best_guesses.length == 1
        return best_guesses.first
      else
        return nil
      end
    end

    def terminating?
      cc = category_counts
      if cc.size == 1
        return cc.keys.first
      end

      certain_categories = cc.keys - ['~']
      if(certain_categories.size == 1)
        certain_prop = cc[certain_categories.first].to_f/(cc[certain_categories.first] + cc['~'])
        if certain_prop > 0.3
          return certain_categories.first
        end
      end

      return false
    end

  end
end