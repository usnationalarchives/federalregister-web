class SearchPresenter::Document < SearchPresenter::Base
  def search
    @search ||= Search::Document.new(params)
  end
end
