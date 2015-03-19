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

  def any_document_counts?
    !document_counts.empty?
  end

  def document_counts
   DocumentTypeFacet.
      search(:conditions => {:publication_date => {:is => date}}).map { |doc_type_facet|
        DocCount.new(
          slug: doc_type_facet.attributes["slug"],
          count: doc_type_facet.attributes["count"],
          search_conditions: doc_type_facet.search_conditions,
          name: document_types[doc_type_facet.attributes["slug"]]
        )
      }
  end

    class DocCount
      vattr_initialize [
        :slug,
        :count,
        :search_conditions,
        :name
      ]
    end

  def significant_documents
    SignificantDocument.new(
      object: retrieve_significant_docs,
      count: retrieve_significant_docs.inject(0){|sum, d| sum += d.attributes["count"]; sum},
      search_conditions: retrieve_significant_docs.conditions
      )
  end
    class SignificantDocument
      vattr_initialize [
        :object,
        :count,
        :search_conditions
      ]
    end

  def page_count
    #TBD
  end

  def document_types
    DOCUMENT_TYPES
  end

  private
  def retrieve_significant_docs
    @significant_docs ||= DocumentTypeFacet.search(:conditions => {:significant => 1, :publication_date => {:is => date}})
  end

end

