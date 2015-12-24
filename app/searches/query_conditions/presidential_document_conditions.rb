class QueryConditions::PresidentialDocumentConditions < QueryConditions::DocumentConditions
  def self.executive_orders(president, year)
    {
      conditions: {
        president: president.identifier,
        presidential_document_type: 'executive_order',
        publication_date: {
          year: year
        }
      }
    }
  end

  def self.executive_orders_for(president)
    {
      conditions: {
        president: president.identifier,
        presidential_document_type: 'executive_order',
        publication_date: {
          gte: president.starts_on,
          lte: president.ends_on
        }
      }
    }
  end
end
