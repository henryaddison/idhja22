module Idhja22
  class IncompleteTree < StandardError; end
  class Dataset
    class BadData < ArgumentError; end
    class InsufficientData < BadData; end
    class NonUniqueAttributeLabels < BadData; end
    class Datum
      class UnknownAttributeLabel < BadData; end
      class UnknownAttributeValue < BadData; end
      class UnknownCategoryLabel < BadData; end
      class UnknownCategoryValue < BadData; end
    end
  end
end
