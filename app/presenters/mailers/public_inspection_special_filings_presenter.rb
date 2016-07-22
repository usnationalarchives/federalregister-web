class Mailers::PublicInspectionSpecialFilingsPresenter < TableOfContentsSpecialFilingsPresenter
  def document_partial
    'public_inspection_document_issues/mailer/document_details'
  end
end
