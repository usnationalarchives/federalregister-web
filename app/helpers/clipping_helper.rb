module ClippingHelper
  def document_numbers_for_javascript(clippings)
    clippings.group_by(&:document_number).map do |document_number, clippings|
      folder_array = clippings.map{|c| c.folder.present? ? c.folder.slug : "my-clippings"}.uniq
      { document_number => folder_array }
    end
  end

  def csv_download_tag(text, clippings)
    return unless clippings

    base_url = "http://api.federalregister.gov/v1/articles"
    document_numbers = clippings.map{|c| c.document_number}.join(',')
    fields = [:citation,
              :type,
              :title,
              :publication_date,
              :start_page,
              :end_page,
              :agency_names,
              :html_url,
              :pdf_url]
    field_params = fields.map{|f| "fields[]=#{f.to_s}"}.join('&')

    url = "#{base_url}/#{document_numbers}.csv?#{field_params}"

    content_tag(:a, :href => url) do
      content_tag(:span, '', :class => "icon-fr2 icon-fr2-download") +
      text
    end
  end
end
