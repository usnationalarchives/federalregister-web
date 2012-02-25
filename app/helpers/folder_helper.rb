module FolderHelper
  def folder_details_for_javascript(folders)
    if user_signed_in?
      arr = javascript_clipboard_for_user
      folders.map do |folder| 
        arr << {:name => folder.name, :slug => folder.slug, :doc_count => folder.clippings.count, :documents => folder.clippings.map{|c| c.document_number} }
      end
    else
      arr = javascript_clipboard_for_non_user
    end

    
    
    {:folders => arr}
  end

  def javascript_clipboard_for_user
    clippings_in_clipboard = Clipping.all(:conditions => {:user_id => current_user.id, :folder_id => nil })
    [ {:name => 'My Clipboard', :slug => 'my-clippings', :doc_count => clippings_in_clipboard.count, :documents => clippings_in_clipboard.map{|c| c.document_number} } ]
  end

  def javascript_clipboard_for_non_user
    if cookies[:document_numbers].present? 
      document_numbers = Clipping.retrieve_document_numbers( cookies[:document_numbers] )
    else
      document_numbers = []
    end
    
    [ {:name => 'My Clipboard', :slug => 'my-clippings', :doc_count => document_numbers.count, :documents => document_numbers } ]
  end
end
