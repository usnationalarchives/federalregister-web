class FrBox::Official < FrBox::Base
  def initialize(options={})
    super(
      default_options.deep_merge(options)
    )
  end

  def default_options
    super.deep_merge({
      css_selector: 'fr-box-official',
      stamp_icon: 'icon-fr2-NARA1985Seal'
    })
  end
end
