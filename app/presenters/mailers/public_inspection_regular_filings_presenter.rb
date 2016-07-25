class Mailers::PublicInspectionRegularFilingsPresenter < TableOfContentsRegularFilingsPresenter
  attr_reader :mailing_list

  def initialize(date, filter_to_documents, mailing_list)
    @mailing_list = mailing_list
    super(date, filter_to_documents)
  end

  def mailing_list_title
    mailing_list.title
  end

  def document_partial
    'public_inspection_document_issues/mailer/document_details'
  end
end
