class ClippingDecorator < ApplicationDecorator
  decorates :clipping

  def clipped_at
    if clipping.created_at
      clipping.created_at.to_formatted_s(:date)
    else
      "<span class='unsaved'>Unsaved</span>".html_safe
    end
  end

  def article
    ArticleDecorator.decorate(model.article)
  end

  def commented_on?
    comment.present?
  end
end
