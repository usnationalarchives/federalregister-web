class PresidentialDocumentsPresenter
  SUBTYPES =  {
    "determination" => "Determination", 
    "executive_order" => "Executive Order", 
    "memorandum" => "Memorandum",
    "notice" => "Notice",
    "proclamation" => "Proclamation"
  }

  def latest_document_by_type(time_ago)
    subtypes_for_homepage = SUBTYPES.select{|subtype, subtype_string| ["executive_order", "notice", "proclamation"].include? subtype} #Filtering the hash down
    docs = nil
    grouped_results = nil 
    
    start_date = time_ago.months.ago
    end_date = Time.now
    loop do 
      docs = search_for_docs(start_date, end_date)
      grouped_results = docs.group_by(&:subtype)
      needed_subtypes = subtypes_for_homepage.values
      returned_subtypes = grouped_results.keys
      break if (needed_subtypes - returned_subtypes).empty? == true 
      start_date -= 2.months
    end

    results = {}
    subtypes_for_homepage.each do |subtype, subtype_string|
      results[subtype] = grouped_results[subtype_string].first
    end
    results
  end
 
  def document_counts_for(date_in_month)
    start_date = date_in_month.beginning_of_month
    end_date = date_in_month.end_of_month
    doc_counts = document_counts(start_date, end_date).
      map{ |facet|
        PresidentialDocumentTypes.new(
          name: facet.name,
          document_type: facet.slug,
          document_count: facet.count,
          document_count_search_conditions: facet.search_conditions #It breaks at this point: Ask Bob
        )
      }
    Hash[doc_counts.map {|pres_doc| [pres_doc.document_type, pres_doc]}]
  end

    class PresidentialDocumentTypes
      vattr_initialize [
        :name,
        :document_type,
        :document_count,
        :document_count_search_conditions,
      ]
    end

#======================================================================
  private

  def document_counts(start_date, end_date)
    PresidentialDocumentsFacet.search(
      Facets::QueryConditions.published_within(start_date, end_date)
    ) 
  end

  def search_for_docs(start_date, end_date)
    FederalRegister::Document.search(
      conditions: {
        type: 'PRESDOCU',
        publication_date: {
          gte: start_date,
          lte: end_date
        }
      },
      fields: [
        'document_number',
        'executive_order_number',
        'html_url',
        'publication_date',
        'subtype',
        'title',
        'type',
      ],
      per_page: '100'
    )
  end

end

