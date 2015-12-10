# the inherit box gets it's style from it's context on the page
# it can therefor only be used inside of another FR Box.
# useful for tooltips or similar boxes that should mirror their context
class FrBox::Inherit < FrBox::Base
  def initialize(options={})
    super(
      default_options.deep_merge(options)
    )
  end

  def default_options
    super.deep_merge({
      css_selector: 'fr-box-inherit',
    })
  end
end
