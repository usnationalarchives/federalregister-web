class StatisticType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      identifier: 'document_type',
      header_csv_index: 3,
      name: 'Count by Document Category',
      footnote_count: 0
    },
    {
      identifier: 'page_count',
      header_csv_index: 4,
      name: 'Page Count By Document Category',
      footnote_count: 6
    },
  ]
end
