class DocumentIssuePresenter
  DOCUMENT_TYPES = {
    "NOTICE" => "Notice",
    "PRORULE" => "Proposed Rule",
    "RULE" => "Rule",
    "PRESDOCU" => "Presidential Document"
  }

  attr_reader :date

  def initialize(date)
    @date = date
  end

  def document_counts
   @document_counts ||= DocumentTypeFacet.
      search(
        conditions: {
          publication_date: {is: date}
        }
      )
  end

  def significant_document_counts
    SignificantDocument.new(documents: significant_docs)
  end

  class SignificantDocument
    vattr_initialize [:documents]

    def name
      'Significant Document'
    end

    def count
      @count = documents.inject(0){|sum, d| sum += d.count; sum}
    end

    def search_conditions
      documents.conditions
    end
  end

  def page_count
    return @page_count if @page_count

    sorted = documents.sort_by(&:start_page)
    if sorted.present?
      @page_count = sorted.last.end_page - sorted.first.start_page + 1 #inclusive
    else
      @page_count = 0
    end
  end

  private

  def documents
    @documents ||= FederalRegister::Document.search(
      conditions: {
        publication_date: {is: date},
      },
      fields: [:end_page, :publication_date, :start_page],
    )
  end

  def significant_docs
    @significant_docs ||= DocumentTypeFacet.search(
      conditions: {
        significant: 1,
        publication_date: {is: date}
      }
    )
  end
end

