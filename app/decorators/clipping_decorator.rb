class ClippingDecorator < ApplicationDecorator
  decorates :clipping
  delegate :size,
           :each,
           :document_number,
           :document,
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

  def article
    DocumentDecorator.decorate(model.article)
  end

  def commented_on?
    comment.present?
  end
end
