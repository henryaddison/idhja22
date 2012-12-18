module Idhja22
  class BinaryClassifier

    class << self
      # Trains a classifier using the provided Dataset.
      def train(dataset, opts = {})
        attributes_to_use = (opts[:attributes] || dataset.attribute_labels)
        classifier = new
        classifier.train(dataset, attributes_to_use)
        return classifier
      end

      # Takes a dataset and splits it randomly into training and validation data. 
      # Uses the training data to train a classifier whose perfomance then measured using the validation data.
      # @param [Float] Proportion of dataset to use for training. The rest will be used to validate the resulting classifier.
      def train_and_validate(dataset, opts = {})
        opts[:"training-proportion"] ||= 0.5
        training_set, validation_set = dataset.split(opts[:"training-proportion"])
        tree = self.train(training_set, opts)
        validation_value = tree.validate(validation_set)
        return tree, validation_value
      end

      # see #train
      # @note Takes a CSV filename rather than a Dataset
      def train_from_csv(filename, opts={})
        ds = Dataset.from_csv(filename)
        train(ds, opts)
      end

      # see #train_and_validate
      # @note Takes a CSV filename rather than a Dataset
      def train_and_validate_from_csv(filename, opts={})
        ds = Dataset.from_csv(filename)
        train_and_validate(ds, opts)
      end
    end

    def validate(ds)
      output = 0
      ds.data.each do |validation_point|
        begin
          prob = evaluate(validation_point)
          output += (validation_point.category == 'Y' ? prob : 1.0 - prob)
        rescue Idhja22::Dataset::Datum::UnknownAttributeValue
          # if don't recognised the attribute value in the example, then assume the worst:
          # will never classify this point correctly
          # equivalent to output += 0 but no point running this
        end
      end
      return output.to_f/ds.size.to_f
    end
  end
end