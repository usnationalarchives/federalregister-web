class DocumentType
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def granule_class
    @granule_class ||= case type.downcase
    when 'rule'
      'rule'
    when 'proposed rule'
      'proposed_rule'
    when 'notice'
      'notice'
    when 'presidential document'
      'presidential_document'
    when 'uncategorized document'
      'uncategorized'
    when 'sunshine act document'
      'notice'
    when 'correction'
      'correct'

    when 'prorule'
      'proposed_rule'
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
