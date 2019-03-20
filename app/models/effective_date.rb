class EffectiveDate

  def self.find_by_start_date_and_end_date(start_date, end_date)
    response = HTTParty.get(url, query: {start_date: start_date.to_s(:iso), end_date: end_date.to_s(:iso)})
    response.parsed_response if response.code == 200
  end

  private

  def self.url
    "#{Settings.federal_register.api_url}/effective-dates"
  end

end
