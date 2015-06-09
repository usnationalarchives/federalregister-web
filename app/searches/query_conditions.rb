class QueryConditions
  def self.published_on(date)
    {
      conditions: {
        publication_date: {
          is: iso(date)
        }
      }
    }
  end

  private

  def self.iso(date)
    if date.is_a?(Date)
      date.to_s(:iso)
    elsif date =~ /(\d{4})-(\d{2})-(\d{2})/
      date
    else
      Date.parse(date).to_s(:iso)
    end
  end
end
