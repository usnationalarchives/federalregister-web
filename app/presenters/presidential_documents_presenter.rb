class PresidentialDocumentsPresenter
  HOMEPAGE_TYPES = [
    "determination",
    "executive_order",
    "memorandum",
    "notice",
    "proclamation",
  ]

  HIGHLIGHTED_HOMEPAGE_TYPES = [
    "executive_order",
    "notice",
    "proclamation"
  ]

  def subtypes
    @subtypes ||= PresidentialDocumentType.all.
      sort_by(&:name).
      select{|pdt| HOMEPAGE_TYPES.include?(pdt.identifier)}
  end

  def subtypes_for_homepage
    @homepage_subtypes ||= PresidentialDocumentType.all.
      sort_by(&:name).
      select{|pdt| HIGHLIGHTED_HOMEPAGE_TYPES.include?(pdt.identifier)}
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

  def document_facets_for_month(date)
    PresidentialDocumentsFacet.search(
      QueryConditions::DocumentConditions.
        published_within(
          date.beginning_of_month,
          date.end_of_month
        )
    )
  end

  private

  def build_results(start_date, end_date, previous_results={})
    docs = presidential_documents_for(start_date, end_date).group_by(&:subtype)

    subtypes_for_homepage.each do |subtype|
      next if previous_results[subtype.identifier]

      if docs[subtype.name].present?
        previous_results[subtype.identifier] = docs[subtype.name].first
      end
    end

    previous_results
  end

  def required_subtypes_present?(docs)
    (subtypes_for_homepage.map{|st| st.identifier} - docs.keys).empty?
  end

  def presidential_documents_for(start_date, end_date)
    Document.search(
      QueryConditions::DocumentConditions.
        published_within(start_date, end_date).
        deep_merge!({
          conditions: {
            type: 'PRESDOCU',
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
        })
    )
  end

end
