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

  def revoked_and_older_date?
    revoked? &&
    model.last_public_inspection_issue &&
    model.last_public_inspection_issue < Date.current
  end

  def table_of_contents_sorting_algorithm
    lambda {|doc| doc.document_number}
  end

  private

  def revoked?
    publication_date.blank?
  end

end
