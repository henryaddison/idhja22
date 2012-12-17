module Idhja22
  # The main entry class for a training, viewing and evaluating a decision tree.
  class Tree
    attr_accessor :root
    class << self
      # Trains a Tree using the provided Dataset.
      def train(dataset)
        new(dataset, dataset.attribute_labels)
      end

      # Takes a dataset and splits it randomly into training and validation data. 
      # Uses the training data to train a tree whose perfomance then measured using the validation data.
      # @param [Float] Proportion of dataset to use for training. The rest will be used to validate the resulting tree.
      def train_and_validate(dataset, training_proportion=0.5)
        training_set, validation_set = dataset.split(training_proportion)
        tree = self.train(training_set)
        validation_value = tree.validate(validation_set)
        return tree, validation_value
      end

      # see #train
      # @note Takes a CSV filename rather than a Dataset
      def train_from_csv(filename)
        ds = Dataset.from_csv(filename)
        train(ds)
      end

      # see #train_and_validate
      # @note Takes a CSV filename rather than a Dataset
      def train_and_validate_from_csv(filename, training_proportion=0.5)
        ds = Dataset.from_csv(filename)
        train_and_validate(ds, training_proportion)
      end
    end

    def initialize(dataset, attributes_available)
      raise Idhja22::Dataset::InsufficientData, "require at least #{Idhja22::MIN_DATASET_SIZE} data points, only have #{dataset.size} in data set provided" if(dataset.size < Idhja22::MIN_DATASET_SIZE)
      @root = Node.build_node(dataset, attributes_available, 0)
    end

    def get_rules
      rules = root.get_rules
      "if " + rules.join("\nelsif ")
    end

    def ==(other)
      return self.root == other.root
    end

    def evaluate query
      @root.evaluate(query)
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