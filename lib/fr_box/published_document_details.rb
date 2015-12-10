class FrBox::PublishedDocumentDetails < FrBox::Published
  def default_options
    super.deep_merge({
      css_selector: 'fr-box-published-alt',
      description: I18n.t('fr_box.description.published_document_details'),
      title: 'Document Details'
    })
  end
end
