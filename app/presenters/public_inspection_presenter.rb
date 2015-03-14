class PublicInspectionPresenter
  attr_reader :regular_filings, :special_filings

  def initialize(date)
    @regular_filings = RegularFilings.new(date)
    @special_filings = SpecialFilings.new(date)
  end

  def all_filings
    [@regular_filings, @special_filings]
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
      regular_filing_counts.sort_by{|facet|facet.slug}
    end

    def total_count
      regular_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count }
    end

    def total_count_search_conditions
      regular_filing_counts.first.search_conditions if regular_filing_counts.first
    end

    def agency_count
      # Bob will be working on the endpoint and we'll have to do a count of how many different keys there are
    end

    def name
      "Regular Filing"
    end


    private
    def regular_filing_counts
      @regular_filings ||= PublicInspectionFacet.
        search(Facets::QueryConditions.regular_filing_published_on(@date))
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
      special_filing_counts.sort_by{|facet|facet.slug}
    end

    def total_count
      special_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count }
    end

    def total_count_search_conditions
      special_filing_counts.first.search_conditions if special_filing_counts.first
    end

    def agency_count
      # Bob will be working on the endpoint and we'll have to do a count of how many different keys there are
    end

    def name
      "Special Filing"
    end
    

    private
      def special_filing_counts
        @special_filings ||= PublicInspectionFacet.
          search(Facets::QueryConditions.special_filing_published_on(@date))
      end
    end
end