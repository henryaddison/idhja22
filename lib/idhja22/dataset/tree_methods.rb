module Idhja22
  class Dataset
    module TreeMethods
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
      
      def terminating?
        probability > 0.95 || probability < 0.05
      end
    end
  end
end
