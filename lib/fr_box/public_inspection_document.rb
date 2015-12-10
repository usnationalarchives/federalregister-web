class FrBox::PublicInspectionDocument < FrBox::PublicInspection
  def default_options
    super.deep_merge({
      description: I18n.t(
        'fr_box.description.public_inspection_document',
        link: link_to('here', public_inspection_learn_path)
      ),
      title: 'Public Inspection Document'
    })
  end
end
