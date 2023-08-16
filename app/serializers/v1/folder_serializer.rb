class V1::FolderSerializer < ActiveModel::Serializer
  attributes :name, :slug

  # the my-clipboard is a faux folder where we add doc_count and
  # documents as non-persistant attributes - true folders use their
  # AR association
  attribute :doc_count do
    object.doc_count ||
      object.clippings.count
  end

  attribute :documents do
    object.documents ||
      object.document_numbers
  end

  attribute :document_types do
    object.document_types ||
      object.clippings.map{|c| c.document.type.downcase.gsub(" ", "_")}.uniq.compact
  end
end
