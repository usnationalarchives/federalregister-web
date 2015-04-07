class QueryConditions
  def self.published_on(date)
    {
      conditions: {
        publication_date: {
          is: date.to_s(:iso)
        }
      }
    }
  end

  def self.toc_conditions(date)
    { per_page: 1000,
      fields: ['start_page', 'end_page', 'pdf_url','document_number'],
      conditions: {
        publication_date: {
          is: date.to_s(:iso)
        }
      }
    }
  end
end
