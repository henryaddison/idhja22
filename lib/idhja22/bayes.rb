module Idhja22
  class Bayes < BinaryClassifier
    attr_accessor :conditional_probabilities, :prior_probabilities
    class << self
      def calculate_conditional_probabilities dataset, attribute_labels_to_use
        conditional_probabilities = {}
        attribute_labels_to_use.each do |attr_label|
          conditional_probabilities[attr_label] = {}
          dataset.partition_by_category.each do |cat, uniform_category_ds|
            conditional_probabilities[attr_label][cat] = Hash.new(0)
            partitioned_data = uniform_category_ds.partition(attr_label)
            partitioned_data.each do |attr_value, uniform_value_ds|
              conditional_probabilities[attr_label][cat][attr_value] = uniform_value_ds.size.to_f/uniform_category_ds.size.to_f
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

    def evaluate(query)
      nb_values = {}
      total_values = 0

      prior_probabilities.each do |cat, prior_prob|
        nb_value = prior_prob
        conditional_probabilities.each do |attr_label, probs|
          raise Idhja22::Dataset::Datum::UnknownAttributeValue, "Not seen value #{query[attr_label]} for attribute #{attr_label} in training." unless cond_prob = probs[cat][query[attr_label]]
          nb_value *= cond_prob
        end
        total_values += nb_value
        nb_values[cat] = nb_value
      end

      return nb_values['Y']/total_values
    end

    def train(dataset, attributes_to_use)
      self.conditional_probabilities = self.class.calculate_conditional_probabilities(dataset, attributes_to_use)
      self.prior_probabilities = self.class.calculate_priors(dataset)
      return self
    end
  end
end