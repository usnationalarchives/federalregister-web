class PresidentialDocumentsPresenter
  SUBTYPES =  {
    "determination" => "Determination",
    "executive_order" => "Executive Order",
    "memorandum" => "Memorandum",
    "notice" => "Notice",
    "proclamation" => "Proclamation"
  }

  def subtypes
    SUBTYPES
  end

  def subtypes_for_homepage
    @subtypes ||= SUBTYPES.select{|subtype, subtype_string|
      ["executive_order", "notice", "proclamation"].include? subtype
    }
  end

  def latest_document_by_type(time_frame=2.months, ensure_complete=true)
    start_date = Date.today - time_frame
    end_date = Date.today

    results = build_results(start_date, end_date)

    if ensure_complete
      until required_subtypes_present?(results)
        end_date = start_date
        start_date -= time_frame

        results = build_results(start_date, end_date, results)
      end
    end

    results
  end

  def document_counts_for(date)
    start_date = date.beginning_of_month
    end_date = date.end_of_month

    doc_counts = document_counts(start_date, end_date).
      map{ |facet|
        PresidentialDocumentTypeFacet.new(
          name: facet.name,
          document_type: facet.slug,
          document_count: facet.count,
          document_count_search_conditions: facet.search_conditions
        )
      }
    Hash[doc_counts.map {|pres_doc| [pres_doc.document_type, pres_doc]}]
  end

  class PresidentialDocumentTypeFacet
    vattr_initialize [
      :name,
      :document_type,
      :document_count,
      :document_count_search_conditions,
    ]
  end

  private

  def build_results(start_date, end_date, previous_results={})
    docs = presidential_documents_for(start_date, end_date).
      group_by(&:subtype)

    subtypes_for_homepage.each do |subtype, subtype_string|
      next if previous_results[subtype]

      if docs[subtype_string].present?
        previous_results[subtype] = docs[subtype_string].first
      end
    end

    previous_results
  end

  def required_subtypes_present?(docs)
    (subtypes_for_homepage.keys - docs.keys).empty?
  end


  def document_counts(start_date, end_date)
    PresidentialDocumentsFacet.search(
      Facets::QueryConditions.published_within(start_date, end_date)
    )
  end

  def presidential_documents_for(start_date, end_date)
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

