class FrBox::PublicInspectionDocumentToc < FrBox::PublicInspection
  def default_options
    super.deep_merge({
      description: I18n.t(
        "fr_box.description.public_inspection_document_toc.#{options[:filing_type]}",
        link: link_to('here', public_inspection_learn_path)
      ),
      title: 'Public Inspection Issue Table of Contents'
    })
  end
end
