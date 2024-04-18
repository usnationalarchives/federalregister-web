class SearchType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      id: 1,
      name: "Textual",
      identifier: "textual",
    },
    {
      id: 2,
      name: "Neural ML",
      identifier: "neural_ml",
    }
  ]
end
