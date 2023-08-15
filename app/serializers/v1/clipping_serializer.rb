class V1::ClippingSerializer < ActiveModel::Serializer
  attributes :document_number
  has_one :folder

  class FolderSerializer < ActiveModel::Serializer
    attributes :name, :slug
  end
end
