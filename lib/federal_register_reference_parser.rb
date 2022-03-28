class FederalRegisterReferenceParser
  def self.hyperlink_with_fr_defaults(html, date: nil, options: {})
    ReferenceParser.new(only: only, options: {timeout: 5.minutes}).hyperlink(html, options: build_options(date: date, options: options), default: {target: "_blank"})
  end

  def self.ecfr_url(title,part)
    cfr_reference = "#{title} CFR #{part}"
    "https://www.ecfr.gov/cfr-reference?#{{cfr: {reference: cfr_reference}}.to_query}"
  end  

  def self.only
    only = %i[usc email cfr federal_register federal_register_doc_number executive_order public_law patent url_prtpage]
    only << :regulatory_plan if Settings.regulatory_plan
    only
  end

  def self.build_options(date: nil, options: nil)
    date ||= "current"
    {
      cfr: {compare: {on: date}, target: "_blank"},
      eo: {relative: true, target: nil, class: "eo"},
      federal_register: {relative: true, target: nil},
      regulatory_plan: {relative: true, target: nil, class: "regulatory_plan"},
      fr_doc: {relative: true, target: nil, class: nil}
    }.transform_values{ |v| v.merge(options || {}) }
  end
end
