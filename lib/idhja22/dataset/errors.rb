module Idhja22
  class Dataset
    class BadData < ArgumentError; end
    class NonUniqueAttributeLabels < BadData; end
    class Datum
      class UnknownAttribute < BadData; end
      class UnknownCategory < BadData; end
    end
  end
end
