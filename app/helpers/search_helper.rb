module SearchHelper
  def working_search_example(search_term)
    link_to search_term,
      documents_search_path(:conditions => {:term => search_term}),
      :class => 'code-styling',
      :target => "_blank"
  end

  def entry_count_for_search_term(search_term)
    Document.search_metadata(:conditions => {:term => search_term}).count
  end

  def conditions_for_subscription(search)
    search.valid_conditions.except(:publication_date)
  end

  def search_suggestion_title(suggestion, search)
    search_filters = search.filter_summary
    parts = suggestion.filter_summary.map do |suggested_filter|
      if search_filters.include?(suggested_filter)
        suggested_filter
      else
        content_tag(:strong, suggested_filter)
      end
    end

    # TODO: bolding of spelling corrections
    if suggestion.term.present?
      term = if suggestion.prior_term
               SpellChecker.new(:template => self).highlight_corrections(suggestion.prior_term)
             else
               h(suggestion.term)
             end
      parts << "matching " + content_tag(:span, term, :class => "term")
    end

    parts.to_sentence
  end
end
