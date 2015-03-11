class HomepagePublicInspectionIssuePresenter
  attr_reader :date

  def initialize(date)
    @date = date
  end

  def regular_filing_counts
    hsh = Hash.new(0)
    get_regular_filing_counts.map do |filing|
      RegularFiling.new(
        count: filing.count,
        search_conditions: filing.result_set.conditions,
        slug: filing.slug
      )
    end.each {|regular_filing| hsh[regular_filing.slug] = regular_filing }
    hsh
  end
    class RegularFiling
      vattr_initialize [
        :count,
        :search_conditions,
        :slug,
      ]
    end

  def regular_filing_count
    if get_regular_filing_counts.first
      search_conditions = get_regular_filing_counts.first.result_set.conditions 
    else
      search_conditions = nil
    end
    TotalCountRegularFiling.new(
      total_count: get_regular_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count },
      sample_filing: get_regular_filing_counts.try(:first),
      search_conditions: search_conditions #get_regular_filing_counts.first.result_set.conditions
    )
  end
    class TotalCountRegularFiling
      vattr_initialize [
        :total_count,
        :sample_filing,
        :search_conditions
      ]
    end

  private
  def get_regular_filing_counts
    @filings = FederalRegister::Facet::PublicInspectionDocument::Type.
      search(:conditions => {:special_filing => 0, :filed_at => {:is => date }})
  end

end