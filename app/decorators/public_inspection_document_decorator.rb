class PublicInspectionDocumentDecorator < ApplicationDecorator
  delegate_all

  include DocumentDecorator::Shared
  include DocumentDecorator::Officialness

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
