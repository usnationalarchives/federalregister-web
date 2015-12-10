class FrBox::PublishedDocument < FrBox::Published
  def default_options
    super.deep_merge({
      description: I18n.t('fr_box.description.published_document'),
      title: 'Published Document'
    })
  end
end
