class DocumentIssuePresenter
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def document_counts
    hash = Hash.new(0)
    DocumentTypeFacet.
      search(:conditions => {:publication_date => {:is => date}}).each do |type|
        hash[type.slug] = type
      end
    hash
  end

  def significant_documents
    SignificantDocument.new(
      object: retrieve_significant_docs,
      count: retrieve_significant_docs.inject(0){|sum, d| sum += d.count; sum},
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

  private
  def retrieve_significant_docs
    @significant_docs ||= DocumentTypeFacet.search(:conditions => {:significant => 1, :publication_date => {:is => date}})
  end

end

