class Holiday
  def self.all
    return @holidays if @holidays

    response = HTTParty.get(url)
    @holidays = response.parsed_response if response.code == 200
  end

  def self.find_by_date(date)
    date = date.is_a?(String) ? date : date.to_s(:iso)

    all.
      select{|d,n| d == date}.
      map{|d,n| OpenStruct.new(date: Date.parse(d), name: n)}.
      first
  end

  def self.is_a_holiday?(date)
    ! find_by_date(date).nil?
  end

  private

  def self.url
    "#{Settings.services.fr.api_core.internal_base_url}/holidays"
  end
end
