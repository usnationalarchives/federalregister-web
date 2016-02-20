module RouteBuilder::ReaderAidUrls
  extend RouteBuilder::Utils

  def public_inspection_learn_path
    "/reader-aids/using-federalregister-gov/understanding-public-inspection"
  end

  def public_inspection_table_of_effective_dates_path
    "/reader-aids/using-federalregister-gov/understanding-public-inspection/table-of-effective-dates-time-periods"
  end

  def reader_aids_search_help_url
    "#{Settings.federal_register.base_uri}/reader-aids/videos-tutorials/utilizing-complex-search-terms"
  end
end
