class FrBox::PublicInspectionDocumentDetails < FrBox::PublicInspection
  def default_options(options={})
    super.deep_merge({
      css_selector: 'fr-box-public-inspection-alt',
      description: I18n.t('fr_box.description.public_inspection_document_details'),
      title: 'Document Details'
    })
  end
end
