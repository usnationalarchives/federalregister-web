class SearchPresenter::PublicInspection < SearchPresenter::Base
  def search
    @search ||= Search::PublicInspection.new(params)
  end
end
