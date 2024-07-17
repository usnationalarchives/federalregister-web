class ReaderAidsPresenter::HomepagePresenter < ReaderAidsPresenter::Base
  def announcements
    sections['office-of-the-federal-register-announcements']
  end

  def using_fr_presenter
    ReaderAidsPresenter::IndexSectionPresenter.new(
      section_identifier: 'using-federalregister-gov',
      display_count: 8,
      columns: 2,
      item_partial: 'reader_aids/homepage_item',
      item_ul_class: "with-bullets reader-aids"
    )
  end

  def recent_updates_presenter
    ReaderAidsPresenter::IndexSectionPresenter.new(
      display_count: 4,
      section_identifier: 'recent-updates',
      category: 'site-updates',
      columns: 1,
      item_partial: 'reader_aids/homepage_item',
      item_ul_class: "with-bullets reader-aids"
    )
  end
end
