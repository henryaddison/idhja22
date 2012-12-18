module Idhja22
  class BinaryClassifier
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