module DocumentDecorator::RegulationsDotGovInfo
  def display_regulations_dot_gov_enhanced_content?
    regulations_dot_gov_info.present? &&
      !regulations_dot_gov_in_default_docket? &&
      regulations_dot_gov_info_displayable_attributes?
  end

  def regulations_dot_gov_info_displayable_attributes?
    displayable_attributes = [
      'docket_id',
      'regulation_id_number',
      'regulatory_plan',
      ['docket_comments_count', 'comments_url'],
      ['supporting_documents_count', 'supporting_documents']
    ]

    displayable = []

    displayable_attributes.each do |attr|
      if attr.is_a?(Array)
        displayable << attr.all?{|a| regulations_dot_gov_info[a].present?}
      else
        displayable << regulations_dot_gov_info[attr].present?
      end
    end

    displayable.any?{|boolean| boolean == true}
  end

  # default dockets end in _0001, eg: CMS_FRDOC_0001
  def regulations_dot_gov_in_default_docket?
    if Settings.feature_flags.multi_agency_comment_submission
      dockets.all?(&:default_docket?)
    else
      regulations_dot_gov_info["docket_id"].present? &&
        regulations_dot_gov_info["docket_id"].match(/_0001/)
    end
  end

  def regulations_dot_gov_document_id
    regulations_dot_gov_info["document_id"]
  end

end
