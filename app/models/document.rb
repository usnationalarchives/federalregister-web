class Document < FederalRegister::Document

  add_attribute :not_received_for_publication
  add_attribute :explanation

  def score
    OpenSearchExplanationPresenter.new(explanation).overall_score
  end

  def explanation_summary
    OpenSearchExplanationPresenter.new(explanation).summary
  end

  def excluding_parent_agencies
    agency_names = agencies.map{|a| a.name}

    if agency_names.any?{|agency_name| agency_name =~ /Office of the Secretary/i}
      agencies
    else
      parent_agency_ids = agencies.map(&:parent_id).compact
      agencies.reject{|a| parent_agency_ids.include?(a.id) }
    end
  end

  def self.search_fields
    [
      :abstract,
      :agencies,
      :document_number,
      :excerpts,
      :html_url,
      :publication_date,
      :title,
      :type,
      :explanation,
    ]
  end

  def public_inspection_document
    return @public_inspection_document if @public_inspection_document

    begin
      @public_inspection_document = PublicInspectionDocument.find(
        document_number
      )
    rescue FederalRegister::Client::RecordNotFound
      @public_inspection_document = nil
    end
  end

  def president
    President.all.find do |president|
      (president.starts_on..president.ends_on).cover? signing_date
    end
  end
end
