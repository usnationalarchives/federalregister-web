class OpenSearchExplanationPresenter

  def self.summary_formula
    "Overall Score = (Constant + Full Text Score + Neural Score ) * Gaussian Time Decay Factor"
  end

  def initialize(open_search_explanation_raw_explanation)
    @open_search_explanation_raw_explanation = ActiveSupport::HashWithIndifferentAccess.new(open_search_explanation_raw_explanation)
  end

  def overall_score
    open_search_explanation_raw_explanation.fetch(:value)
  end

  def summary
    "(#{constant} + #{full_text_score} + #{neural_score} ) * #{decay_factor}"
  end

  private 

  def constant
    find_search_score(0)
  end

  def full_text_score
    find_search_score(1)
  end

  def neural_score
    find_search_score(2)
  end

  def find_search_score(index)
    open_search_explanation_raw_explanation.dig("details").first.fetch("details").dig(index, "value") || 0
  end

  def decay_factor
    open_search_explanation_raw_explanation.fetch("details").last.fetch("value")
  end

  attr_reader :open_search_explanation_raw_explanation

end
