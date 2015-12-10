class FrBox::PublicInspection < FrBox::Base
  def initialize(options={})
    super(
      default_options.deep_merge(options)
    )
  end

  def default_options
    super.deep_merge({
      css_selector: 'fr-box-public-inspection',
      stamp_icon: 'icon-fr2-stop-hand'
    })
  end
end
