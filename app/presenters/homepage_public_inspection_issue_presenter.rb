class HomepagePublicInspectionIssuePresenter
  FILING_DISPLAY_INFO = { 
    "NOTICE" => {:icon => "notice", :tooltip => "Notices"},
    "PRORULE" => {:icon => "proposed_rule", :tooltip => "Proposed Rules" },
    "RULE" => {:icon => "rule" , :tooltip => "Rules" }
  }

  attr_reader :date

  def initialize(date)
    @date = date
  end

  def regular_filing_counts
    hsh = Hash.new(0)
    get_regular_filing_counts.map do |filing|
      Filing.new(
        count: filing.count,
        search_conditions: filing.result_set.conditions,
        slug: filing.slug
      )
    end.each {|filing| hsh[filing.slug] = filing }
    hsh
  end

  def special_filing_counts
    hsh = Hash.new(0)
    get_special_filing_counts.map do |filing|
      Filing.new(
        count: filing.count,
        search_conditions: filing.result_set.conditions,
        slug: filing.slug
      )
    end.each {|filing| hsh[filing.slug] = filing }
    hsh
  end

    class Filing
      vattr_initialize [
        :count,
        :search_conditions,
        :slug,
      ]
    end

  def regular_filing_count
    if get_regular_filing_counts.first # Guarding against empty hash
      search_conditions = get_regular_filing_counts.first.result_set.conditions 
    else
      search_conditions = nil
    end
    TotalFiling.new(
      total_count: get_regular_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count },
      sample_filing: get_regular_filing_counts.try(:first),
      search_conditions: search_conditions
    )
  end

  def special_filing_count
    if get_special_filing_counts.first # Guarding against empty hash
      search_conditions = get_special_filing_counts.first.result_set.conditions 
    else
      search_conditions = nil
    end
    TotalFiling.new(
      total_count: get_special_filing_counts.inject(0){|total_sum, filing| total_sum + filing.count },
      sample_filing: get_special_filing_counts.try(:first),
      search_conditions: search_conditions
    )
  end

    class TotalFiling
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

  def get_special_filing_counts
    @filings = FederalRegister::Facet::PublicInspectionDocument::Type.
      search(:conditions => {:special_filing => 1, :filed_at => {:is => date }})
  end
end