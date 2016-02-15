module RouteBuilder::Citations
  extend RouteBuilder::Utils

  add_route :select_cfr_citation do |date, title, part, section|
    citation =  "#{title}-CFR-#{part}#{'.' + section.to_s if section.present?}"
    {
      year:             date.strftime('%Y'),
      month:            date.strftime('%m'),
      day:              date.strftime('%d'),
      citation:         citation,
    }
  end
end
