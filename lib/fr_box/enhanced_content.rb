class FrBox::EnhancedContent < FrBox::Base
  def initialize(options={})
    super(
      default_options.deep_merge(options)
    )
  end

  def default_options
    super.deep_merge({
      css_selector: 'fr-box-enhanced',
      description: I18n.t('fr_box.description.enhanced_content'),
      title: 'Enhanced Content'
    })
  end
end
