class SearchType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      id: 1,
      identifier: "lexical",
      name: "Lexical (w/decay)",
      decay: true,
      supports_explain: true,
    },
    {
      id: 2,
      identifier: "lexical_no_decay",
      name: "Lexical (no decay)",
      supports_explain: true,
    },
    {
      id: 3,
      name: "Hybrid (Function min score)",
      decay: true,
      identifier: "hybrid",
      is_hybrid_search: true,
      k_nearest_neighbors: 10,
      min_function_score_for_neural_query: 1.9,
      min_score: nil, # The min score is handled via a somewhat manual function score threshold.  We'll probably want to use the hybrid KNN min score search
      supports_explain: false,
    },
    {
      id: 4,
      name: "Hybrid (KNN min score)",
      decay: true,
      identifier: "hybrid_knn_min_score",
      is_hybrid_search: true,
      k_nearest_neighbors: nil,
      min_function_score_for_neural_query: nil, # The minimum score is handled via the min_score knn query parameters
      min_score: 0.90,
      supports_explain: false,
    }
  ]
end
