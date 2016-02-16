class ReaderAidsPresenter::IndexSectionPresenter < ReaderAidsPresenter::SectionPresenter
  def initialize(config)
    super config

    @columns = config.fetch(:columns) { section_settings[:columns] }
    @display_count = config.fetch(:display_count) { section_settings[:display_count] }
  end
end
