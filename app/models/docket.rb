class Docket < FederalRegister::Base
  add_attribute :id, :title, :agency_name, :documents, :supporting_documents, :supporting_documents_count

  def default_docket?
    id && (id.match? /_0001/)
  end

  def regs_dot_gov_documents
    documents.map do |doc_attributes|
      RegsDotGovDocument.new(doc_attributes.merge('docket' => self))
    end
  end

end
