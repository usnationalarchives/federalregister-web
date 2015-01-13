class ClippingDecorator < ApplicationDecorator
  decorates :clipping
  delegate :size,
           :each,
           :document_number,
           :comment,
           :id,
           :map, to: :clipping

  def clipped_at
    if clipping.created_at
      clipping.created_at
    else
      "<span class='unsaved'>Unsaved</span>".html_safe
    end
  end

  def document
    DocumentDecorator.decorate(model.document)
  end

  def commented_on?
    comment.present?
  end
end
