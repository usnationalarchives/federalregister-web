class DocumentType
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def granule_class
    @granule_class ||= case type
    when 'Rule'
      'rule'
    when 'Proposed Rule'
      'proposed_rule'
    when 'Notice'
      'notice'
    when 'Presidential Document'
      'presidential_document'
    when 'Uncategorized Document'
      'uncategorized'
    when 'Sunshine Act Document'
      'notice'
    when 'Correction'
      'correct'
    end
  end

  def display_type
    type.
      split(" ").
      map(&:capitalize).
      join(" ")
  end

  def icon_wrapper_class(size=nil)
    "rule_type doc_#{granule_class.downcase} #{size}"
  end

  def icon_class
    "icon-fr2 icon-doctype icon-fr2-#{granule_class.downcase}"
  end
end
