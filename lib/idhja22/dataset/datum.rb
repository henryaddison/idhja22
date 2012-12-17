module Idhja22
  class Dataset
    class Datum
      attr_accessor :attributes, :category_label, :attribute_labels 

      def initialize(row, attr_labels, category_label)
        self.category_label = category_label
        raise NonUniqueAttributeLabels, "repeated attributes in #{attr_labels}" unless attr_labels == attr_labels.uniq
        self.attribute_labels = attr_labels
        self.attributes = row
      end

      def to_a
        attributes
      end

      def [](attr_label)
        if index = @attribute_labels.index(attr_label)
          self.attributes[index]
        else
          raise UnknownAttributeLabel, "unknown attribute label #{attr_label} in labels #{@attribute_labels.join(', ')}"
        end
      end
    end

    class Example < Datum
      attr_accessor :category

      def initialize(row, attr_labels, category_label)
        super
        self.category = self.attributes.pop
        raise UnknownCategoryValue, "Unrecognised category: #{@category} - should be Y or N" unless ['Y', 'N'].include?(@category)
      end

      def to_a
        super+[category]
      end
    end
  end
end