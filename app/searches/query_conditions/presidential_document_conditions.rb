class QueryConditions::PresidentialDocumentConditions < QueryConditions::DocumentConditions
  def self.presidential_documents(president, year, document_types)
    president_identifier = president ? president.identifier : nil

    {
      conditions: {
        president: president_identifier,
        presidential_document_type: document_types,
        signing_date: {
          year: year
        },
        type: ["PRESDOCU"],
      },
      include_pre_1994_docs: true
    }
  end

  def self.all_presidential_documents_for(president, document_types)
    {
      conditions: {
        president: president.identifier,
        presidential_document_type: document_types,
        signing_date: {
          gte: president.starts_on,
          lte: president.ends_on
        },
        type: ["PRESDOCU"],
      },
      include_pre_1994_docs: true
    }
  end
end
