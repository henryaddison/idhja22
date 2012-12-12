module Idhja22
  class Dataset
    class Datum
      attr_reader :category, :attributes, :category_label, :attribute_labels

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
  end
end