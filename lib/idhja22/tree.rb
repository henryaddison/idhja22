module Idhja22
  class Tree
    attr_accessor :root
    class << self
      def train(dataset)
        new(dataset, dataset.attribute_labels)
      end

      def train_and_validate(dataset, training_proportion=0.5)
        training_set, validation_set = dataset.split(training_proportion)
        tree = self.train(training_set)
        validation_value = tree.validate(validation_set)
        return tree, validation_value
      end

      def train_from_csv(filename)
        ds = Dataset.from_csv(filename)
        train(ds)
      end

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