module Idhja22
  class Dataset
    module TreeMethods
      def partition(attr_label)
        groups = Hash.new([])
        data.each do |datum|
          groups[datum[attr_label]] += [datum]
        end
        output = Hash.new
        groups.each do |value, data|
          output[value] = Dataset.new(data, attribute_labels, category_label)
        end
        return output
      end

      def entropy
        total = self.size
        return 1.0 if total < Idhja22::MIN_DATASET_SIZE
        category_counts.values.inject(0.0) { |ent, count|  prop = count.to_f/total.to_f; ent-prop*Math.log(prop,2)  }
      end
      
      def terminating?
        probability > Idhja22::TERMINATION_PROBABILITY || probability < 1-Idhja22::TERMINATION_PROBABILITY
      end
    end
  end
end
