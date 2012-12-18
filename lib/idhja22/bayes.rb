module Idhja22
  class Bayes
    attr_accessor :conditional_probabilities, :prior_probabilities
    class << self
      def train dataset, attribute_labels_to_use
        classifier = new
        classifier.conditional_probabilities = calculate_conditional_probabilities(dataset, attribute_labels_to_use)
        classifier.prior_probabilities = calculate_priors(dataset)

        return classifier
      end

      def calculate_conditional_probabilities dataset, attribute_labels_to_use
        conditional_probabilities = {}
        attribute_labels_to_use.each do |attr_label|
          conditional_probabilities[attr_label] = {}
          partitioned_data = dataset.partition(attr_label)
          partitioned_data.each do |attr_value, ds|
            conditional_probabilities[attr_label][attr_value] = Hash.new(0)
            ds.partition_by_category.each do |cat, uniform_ds|
              conditional_probabilities[attr_label][attr_value][cat] = uniform_ds.size.to_f/ds.size.to_f
            end
          end
        end

        return conditional_probabilities
      end

      def calculate_priors dataset
        output = Hash.new(0)
        dataset.category_counts.each do |cat, count|
          output[cat] = count.to_f/dataset.size.to_f
        end
        return output
      end
    end

  end
end