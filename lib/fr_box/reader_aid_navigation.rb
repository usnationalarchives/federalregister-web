class FrBox::ReaderAidNavigation < FrBox::ReaderAid
  def initialize(options={})
    super(
      default_options.deep_merge(options)
    )
  end

  def default_options
    super.deep_merge({
      header: {
        hover: false,
      },
    })
  end
end
