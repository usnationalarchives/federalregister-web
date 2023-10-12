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
    lambda {|doc| [0, 0, doc.document_number] }
  end

  def google_analytics_data_expected?
    # GA data is provided on a delay of 24-48 hours
    filed_at_date = filed_at&.to_date
    filed_at_date != Date.current
  end

  private

  def revoked?
    publication_date.blank?
  end

end
