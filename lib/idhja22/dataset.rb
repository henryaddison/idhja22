require 'csv'
module Idhja22
  class Dataset
    attr_reader :category_label, :attribute_labels, :data
    class BadData < ArgumentError; end
    class NonUniqueAttributeLabels < BadData; end

    class Datum
      attr_reader :category, :attributes, :category_label, :attribute_labels
      class UnknownAttribute < BadData; end
      class UnknownCategory < BadData; end

      def initialize(row, attr_labels, category_label)
        @category_label = category_label
        raise NonUniqueAttributeLabels, "repeated attributes in #{attr_labels}" unless attr_labels == attr_labels.uniq
        @attribute_labels = attr_labels
        @category = row.pop
        raise UnknownCategory, "Unrecognised category: #{@category} - should be Y or N" unless ['Y', 'N'].include?(@category)
        @attributes = row
      end

      def to_a
        attributes+[category]
      end

      def [](attr_label)
        if index = @attribute_labels.index(attr_label)
          @attributes[index]
        else
          raise UnknownAttribute, "unknown attribute label #{attr_label} in labels #{@attribute_labels.join(', ')}"
        end
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
          data << Datum.new(row, attribute_labels, category_label)
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

    def probability
      category_counts['Y'].to_f/size.to_f
    end

    def terminating?
      probability > 0.95 || probability < 0.05
    end

  end
end