module ClippingHelper
  def document_numbers_for_javascript(clippings)
    clippings.group_by(&:document_number).map do |document_number, clippings| 
      folder_array = clippings.map{|c| c.folder.present? ? c.folder.slug : "my-clippings"}.uniq
      { document_number => folder_array }
    end
  end
end
