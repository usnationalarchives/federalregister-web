class PublicInspectionDocumentDecorator < ApplicationDecorator
  delegate_all

  include DocumentDecorator::Shared

  def title
    if model.title.present?
      model.title
    else
      "#{toc_subject} #{toc_doc}"
    end
  end

  def abstract
    return "" unless model.title

    "#{toc_subject} #{toc_doc}"
  end
end
