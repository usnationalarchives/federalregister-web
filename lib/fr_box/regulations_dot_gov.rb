class FrBox::RegulationsDotGov < FrBox::EnhancedContent
  def default_options
    super.deep_merge({
      description: I18n.t('fr_box.description.regulations_dot_gov')
    })
  end
end
