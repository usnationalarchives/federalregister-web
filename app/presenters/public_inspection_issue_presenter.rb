class PublicInspectionIssuePresenter
  attr_reader :agencies, :date, :regular_filings, :special_filings

  def initialize(date)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @regular_filings = RegularFilings.new(@date, self)
    @special_filings = SpecialFilings.new(@date, self)
    @agencies = {}
  end

  def all_filings
    [@regular_filings, @special_filings]
  end

  def issue
    @issue ||= PublicInspectionDocumentIssue.available_on(date)
  end

  class BasicFilings
    attr_reader :publication_date, :public_inspection_issue
    def initialize(date, presenter)
      @publication_date = date
      @public_inspection_issue = presenter.issue
    end

    def formatted_updated_at
      filings.last_updated_at.to_s(:time_then_date)
    end

    def agency_count
      filings.agencies
    end

    def document_count
      filings.documents
    end

    def type
      @type ||= name.downcase.gsub(' ', '-')
    end

    def filing_facets
      @filing_facets ||= PublicInspectionIssueTypeFacet.search(
        QueryConditions::PublicInspectionDocumentConditions.
          published_on(publication_date)
      ).first
    end


    def special_filing?
      type == 'special-filing'
    end
  end

  class RegularFilings < BasicFilings
    def name
      "Regular Filing"
    end

    def search_conditions(type=nil)
      conditions = QueryConditions::PublicInspectionDocumentConditions.regular_filing
      if type
        conditions.deep_merge!(
          {
            conditions: {type: DocumentType.new(type).granule_class}
          }
        )
      end
    end

    def filings
      public_inspection_issue.regular_filings
    end

    def document_type_facets
      filing_facets.regular_filings.document_types
    end
  end

  class SpecialFilings < BasicFilings
    def name
      "Special Filing"
    end

    def search_conditions(type=nil)
      conditions = QueryConditions::PublicInspectionDocumentConditions.special_filing
      if type
        conditions.deep_merge!(
          {
            conditions: {type: DocumentType.new(type).granule_class}
          }
        )
      end
    end

    def filings
      public_inspection_issue.special_filings
    end

    def document_type_facets
      filing_facets.regular_filings.document_types
    end
  end
end
