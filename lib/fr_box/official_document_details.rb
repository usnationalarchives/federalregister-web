class FrBox::OfficialDocumentDetails < FrBox::Official
  def default_options
    super.deep_merge({
      css_selector: 'fr-box-official-alt',
      description: I18n.t('fr_box.description.official_document_details'),
      title: 'Document Details'
    })
  end
end
