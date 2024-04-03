class StatisticType < ActiveHash::Base
  include ActiveHash::Enum
  enum_accessor :identifier

  self.data = [
    {
      identifier: 'document_type',
      header_csv_index: 3,
      name: 'Document Count by Category',
      footnote_count: 1
    },
    {
      identifier: 'page_count',
      header_csv_index: 4,
      name: 'Page Count By Category',
      footnote_count: 3
    },
  ]
end
