class FrBox::PublishedDocumentToc < FrBox::Published
  def default_options
    super.deep_merge({
      description: I18n.t('fr_box.description.published_document_toc'),
      title: 'Document Issue Table of Contents'
    })
  end
end
