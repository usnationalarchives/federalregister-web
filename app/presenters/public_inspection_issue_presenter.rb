class PublicInspectionIssuePresenter
  attr_reader :regular_filings, :special_filings

  def initialize(date=nil)
    if date
      result_set = FederalRegister::PublicInspectionDocument.available_on(date)
    else
      result_set = FederalRegister::PublicInspectionDocument.current
    end

    @regular_filings = RegularFilings.new(result_set)
    @special_filings = SpecialFilings.new(result_set)
  end

  class BasicFilings
    attr_reader :agency_count, :count

    def agency_count
      documents.group_by{|d| d.agencies.last.name}.count
    end

    def document_count
      documents.count
    end

    def counts_by_type
      documents.group_by(&:type).map{|k,v| {k => v.count}}
    end

    def formatted_updated_at
      updated_at.to_s(:time_then_date)
    end

    def type
      name.downcase.gsub(' ', '-')
    end

    def special_filing?
      type == 'special-filing'
    end
  end

  class RegularFilings < BasicFilings
    attr_reader :documents, :updated_at

    def initialize(result_set)
      @documents = DocumentDecorator.decorate_collection(
        result_set.results.select{|d| d.filing_type == 'regular'}
      )
      @updated_at = result_set.special_filings_updated_at
    end

    def name
      "Regular Filing"
    end
  end

  class SpecialFilings < BasicFilings
    attr_reader :documents, :updated_at

    def initialize(result_set)
      @documents = DocumentDecorator.decorate_collection(
        result_set.results.select{|d| d.filing_type == 'special'}
      )
      @updated_at = result_set.special_filings_updated_at
    end

    def name
      "Special Filing"
    end
  end
end
