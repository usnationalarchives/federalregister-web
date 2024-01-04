class PresidentialDocumentType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  OTHER_PRESIDENTIAL_DOCUMENTS = %w(determination memorandum notice other presidential_order)

  self.data = [
    {id: 1, name: "Determination",      node_name: "DETERM",    identifier: "determination"},
    {id: 2, name: "Executive Order",    node_name: "EXECORD",   identifier: "executive_order", include_pre_1993: true},
    {id: 3, name: "Memorandum",         node_name: "PRMEMO",    identifier: "memorandum"},
    {id: 4, name: "Notice",             node_name: "PRNOTICE",  identifier: "notice"},
    {id: 5, name: "Proclamation",       node_name: "PROCLA",    identifier: "proclamation"},
    {id: 6, name: "Presidential Order", node_name: "PRORDER",   identifier: "presidential_order"},
    {id: 7, name: "Other",              node_name: "OTHER",     identifier: "other"},
  ]

  def self.other_presidential_document_types
    all.select do |type|
      OTHER_PRESIDENTIAL_DOCUMENTS.include? type.identifier
    end
  end

  # patch in an amalgamation type (administrative orders)
  def self.find(type)
    if type == 'other_presidential_document'
      doc_type = new(
        name: "Other Presidential Document",
        identifier: other_presidential_document_types.map(&:identifier),
        id: other_presidential_document_types.map(&:id),
      )
      doc_type.attributes[:type] = 'other_presidential_document'
    else
      doc_type = where(identifier: type).first
    end

    raise ActiveRecord::RecordNotFound unless doc_type
    doc_type
  end

  def type
    attributes[:type] || identifier
  end

  def slug
    type.pluralize.gsub('_', '-')
  end
end
