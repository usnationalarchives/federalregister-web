class FolderDecorator < ApplicationDecorator
  decorates :folder

  def self.for_javascript
    folders = Folder.for_current_user
    clippings_in_clipboard = Clipping.all(:conditions => {:user_id => User.stamper, :folder_id => nil })
    arr = [ {:name => 'My Clipboard', :slug => 'my-clippings', :doc_count => clippings_in_clipboard.count, :documents => clippings_in_clipboard.map{|c| c.document_number} } ]
    folders.map do |folder| 
      arr << {:name => folder.name, :slug => folder.slug, :doc_count => folder.clippings.count, :documents => folder.clippings.map{|c| c.document_number} }
    end
    {:folders => arr}
  end
end
