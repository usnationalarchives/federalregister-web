module ClippingHelper
  def document_numbers_for_javascript(clippings)
    clippings.group_by(&:document_number).map do |document_number, clippings|
      folder_array = clippings.map{|c| c.folder.present? ? c.folder.slug : "my-clippings"}.uniq
      { document_number => folder_array }
    end
  end

  def csv_download_tag(text, clippings)
    return unless clippings

    document_numbers = clippings.map{|c| c.document_number}.join(',')
    fields = [
      :agency_names,
      :citation,
      :end_page,
      :html_url,
      :pdf_url,
      :publication_date,
      :start_page,
      :title,
      :type,
    ]
    field_params = fields.map{|f| "fields[]=#{f.to_s}"}.join('&')

    path = "/api/v1/documents/#{document_numbers}.csv?#{field_params}"

    content_tag(:a, :href => path) do
      content_tag(:span, '', :class => "icon-fr2 icon-fr2-download") +
      text
    end
  end
end
