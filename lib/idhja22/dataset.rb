require 'csv'
module Idhja22
  class Dataset

    class Datum
      attr_reader :category, :attributes
      def initialize(row)
        @category = row.pop
        @attributes = row
      end
    end

    attr_reader :category_label, :attribute_labels, :data
    class << self
      def from_csv(filename)
        new(CSV.read(filename))
      end
    end

    def initialize(data)
      labels = data.shift
      @category_label = labels.pop
      @attribute_labels = labels
      @data = []
      data.each do |row|
        @data << Datum.new(row)
      end
    end
  end
end