class FrBox::OfficialDocument < FrBox::Official
  def default_options
    super.deep_merge({
      description: I18n.t('fr_box.description.official_document'),
      title: 'Published & Verified Document'
    })
  end
end
