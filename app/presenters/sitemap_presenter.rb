class SitemapPresenter
  extend Memoist

  def documents
    Array.new.tap do |docs|
      # NOTE: Used since we can't bulk query api-core for all document records
      queryable_date_ranges.each do |date_range|
        page = 0

        while page == 0 || results.next_url.present? do
          page = page + 1
          results = get_documents(date_range, page)
          results.each {|doc| docs << DocumentDecorator.new(doc) }
        end
      end
    end
  end
  memoize :documents

  def get_documents(date_range, page)
    Document.search(
      conditions: {
        publication_date: {
          gte: date_range.first,
          lte: date_range.last
        }
      },
      fields: [
        :document_number,
        :publication_date,
        :slug,
      ],
      order: 'oldest',
      per_page: 2000,
      page: page
    )
  end

  def document_issues
    issues = Array.new

    queryable_year_collections.each do |year_collection|
      #NOTE: the API endpoint seems to return inaccurate results when more than 20 years are requested hence the need to break up the requests
      DocumentIssue.
        within(
          Date.new(year_collection.first,1,1),
          Date.new(year_collection.last,12,31)
        ).
        each do |document_issue|
          if document_issue.count > 0
            issues << document_issue
          end
        end
    end

    issues
  end

  def public_inspection_document_issues
    issue = Array.new

    queryable_year_collections.each do |year_collection|
      PublicInspectionDocumentIssue.
        within(
          Date.new(year_collection.first,1,1),
          Date.new(year_collection.last,12,31)
        ).
        each do |public_inspection_document_issue|
        if public_inspection_document_issue.has_documents?
          issue << public_inspection_document_issue
        end
      end
    end

    issue
  end

  def public_inspection_documents
    docs = Array.new

    TableOfContentsSpecialFilingsPresenter.
      new(current_public_inspection_publication_date).
      documents.
      each {|doc| docs << doc}

    TableOfContentsRegularFilingsPresenter.
      new(current_public_inspection_publication_date).
      documents.
      each {|doc| docs << doc}

    docs
  end

  def topics
    TopicFacet.search.sort{|a, b| a.name <=> b.name}
  end

  def executive_orders
    eos = Array.new

    ExecutiveOrderPresenter.new.orders_by_president_and_year.each do |president, eo_collections|
      eo_collections.each do |eo_collection|
        eo_collection.results.each do |eo|
          eos << eo
        end
      end
    end

    eos
  end


  private

  def current_public_inspection_publication_date
    PublicInspectionDocumentIssue.current.publication_date
  end
  memoize :current_public_inspection_publication_date

  MAX_YEARS_QUERIED = 10
  def queryable_year_collections
    (START_YEAR..end_year).to_a.in_groups_of(MAX_YEARS_QUERIED, false)
  end

  START_YEAR = 1994
  def queryable_date_ranges
    (START_YEAR..end_year).to_a.each_with_object([]) do |year, ranges|
      [1,4,7,10].each do |first_month|
        quarter_start = Date.new(year, first_month, 1)
        quarter_end   = quarter_start.advance(months: 2).end_of_month
        ranges << (quarter_start..quarter_end)
      end
    end
  end

  def end_year
    Date.current.year
  end

end
