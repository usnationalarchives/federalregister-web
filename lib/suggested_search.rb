class SuggestedSearch < FederalRegister::SuggestedSearch

  def example_documents
    FederalRegister::Document.search(:conditions => search_conditions).results
  end

  def count_comments_open_for_comment
    count = 0
    facet_searches = FederalRegister::Facet::Document::Yearly.search(
      conditions: {
        publication_date: {
          gte: Date.current - 2.years
        },
        comment_date: {
          gte: Date.current
        }
      }.merge(search_conditions)
    ).each {|year_result|count += year_result.count}
    count
  end

end
