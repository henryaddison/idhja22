require 'csv'
module Idhja22
  class Dataset
    attr_reader :category_label, :attribute_labels
    class << self
      def from_csv(filename)
        new(CSV.read(filename))
      end
    end

    def initialize(data)
      labels = data.shift
      @category_label = labels.pop
      @attribute_labels = labels
    end
  end
end