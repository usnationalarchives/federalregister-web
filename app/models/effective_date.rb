class EffectiveDate

  def self.find_by_start_date_and_end_date(start_date, end_date)
    response = HTTParty.get(url, query: {start_date: start_date, end_date: end_date})
    response.parsed_response if response.code == 200
  end

  private

  def self.url
    return 'http://www.mocky.io/v2/5c9033263600005500f10056' #TODO: Remove stub

    "#{Settings.federal_register.api_url}/effective_dates"
  end

end
