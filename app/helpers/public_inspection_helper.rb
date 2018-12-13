module PublicInspectionHelper
  def public_inspection_uscode_link
    link_to '44 U.S.C. 1503 & 1507',
      "https://www.govinfo.gov/content/pkg/USCODE-2009-title44/html/USCODE-2009-title44-chap15.htm"
  end

  def utility_bar_warning_text
    "If you are using public inspection listings for legal research, you
    should verify the contents of the documents against a final, official
    edition of the Federal Register. <strong>Only official editions of the
    Federal Register provide legal notice to the public and judicial notice
    to the courts under #{public_inspection_uscode_link}.</strong>
    Learn more #{link_to 'here', public_inspection_learn_path}.".html_safe
  end
end
