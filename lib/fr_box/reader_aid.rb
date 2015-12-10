class FrBox::ReaderAid < FrBox::Base
  def initialize(options={})
    super(
      default_options.deep_merge(options)
    )
  end

  def default_options
    super.deep_merge({
      content_block_html: {class: 'simple'},
      css_selector: 'fr-box-reader-aid',
      description: I18n.t('fr_box.description.reader_aid'),
      title: 'Reader Aids',
    })
  end
end
