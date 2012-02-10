class FolderDecorator < ApplicationDecorator
  decorates :folder

  def self.for_javascript
    folders = all
    folders.map do |folder| 
      { folder.id => {:name => folder.name, :slug => folder.slug, :doc_count => folder.clippings.count} }
    end
  end

  def clipping_count_display
    content_tag(:span, "(#{model.clippings.count.to_s})", :class => 'document_count').html_safe
  end
end
