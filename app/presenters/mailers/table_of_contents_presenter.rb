class Mailers::TableOfContentsPresenter < TableOfContentsPresenter
  attr_reader :mailing_list

  def initialize(date, filter_to_documents, mailing_list)
    @mailing_list = mailing_list
    super(date, filter_to_documents)
  end

  def mailing_list_title
    mailing_list.title
  end

  def document_partial
    'document_issues/mailer/document_details'
  end

  private

  def document_fields
    [
      :abstract,
      :agencies,
      :citation,
      :document_number,
      :end_page,
      :html_url,
      :pdf_url,
      :publication_date,
      :start_page,
      :title,
    ]
  end
end
