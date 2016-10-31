xml.instruct! :xml, :version => "1.0"

xml.rss :version => "2.0" do

  xml.channel do
    xml.title @presenter.title
    xml.link reader_aids_section_url(@presenter.section_identifier)
    xml.description @presenter.title

    @presenter.items_for_display.each do |item|
      xml.item do
        xml.title item.formatted_title
        xml.link item.url(@presenter.section_identifier)
        xml.description item.rss_excerpt
      end
    end
  end

end
