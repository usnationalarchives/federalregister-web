class PublicInspectionPresenter
  attr_reader :regular_filings, :special_filings

  def initialize(date)
    @regular_filings = RegularFilings.new(date)
    @special_filings = SpecialFilings.new(date)
  end

  class BasicFilings
    attr_reader :agency_count, :count

    def formatted_updated_at
      updated_at.to_s(:formal_with_time)
    end

  end

  class RegularFilings < BasicFilings
    attr_reader :agency_count, :document_counts, :updated_at

    def initialize(date)
      @date = date
      @agency_count #= agencies_for_regular_filings.sum_the_count
      @updated_at = Time.now #TODO: This will be coming back from the FR API
    end

    def counts_by_identifier
      regular_filing_counts.map do |doc_set| #Adjust naming conventions and removing get.
        DocumentTypeFacet.new(
          {},
          {},
          {
          :count => doc_set.count,
          :search_parameters => doc_set.result_set.conditions,
          :identifier => doc_set.slug
          }
        )
      end.sort_by{|doc_set|doc_set.identifier}
    end

    def total_count_search_conditions
      if regular_filing_counts.first #check for nil
        regular_filing_counts.first.result_set.conditions
      else
        nil
      end
    end

    def agency_count
      # Bob will be working on the endpoint and we'll have to do a count of how many different keys there are
    end


    def total_count
      regular_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count }
    end


    private
    def regular_filing_counts
      @regular_filings ||= FederalRegister::Facet::PublicInspectionDocument::Type.
        search(:conditions => {:special_filing => 0, :filed_at => {:is => @date }})
    end

  end

  class SpecialFilings < BasicFilings
    attr_reader :agency_count, :document_counts, :updated_at, :date
    def initialize(date)
      @date = date
      # @agency_count = nil
      @updated_at = Time.now #TODO: This will be coming back from the FR API
    end

    def counts_by_identifier
      special_filing_counts.map do |doc_set| #Adjust naming conventions and removing get.
        DocumentTypeFacet.new(
          {},
          {},
          {
          :count => doc_set.count,
          :search_parameters => doc_set.result_set.conditions,
          :identifier => doc_set.slug
          }
        )
      end.sort_by{|doc_set|doc_set.identifier}
    end

    def total_count_search_conditions
      special_filing_counts.first.result_set.conditions if special_filing_counts.first #check for nil
    end

    def agency_count
      # Bob will be working on the endpoint and we'll have to do a count of how many different keys there are
    end


    def total_count
      special_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count }
    end


    private
      def special_filing_counts
        @special_filings ||= FederalRegister::Facet::PublicInspectionDocument::Type.
          search(:conditions => {:special_filing => 1, :filed_at => {:is => date }})
      end
    end
end


    # class DocType
    #   vattr_initialize [
    #     :count,
    #     :identifier,
    #     :search_conditions,
    #   ]
    # end

    # def counts_by_identifier
    #   get_regular_filing_counts.map do |doc_set| #Adjust naming conventions and removing get.
    #     DocType.new(
    #       count: doc_set.count,
    #       search_conditions: doc_set.result_set.conditions,
    #       identifier: doc_set.slug
    #     )#.sort_by{|doc_set| doc_set.identifier}
    #   end
    # end