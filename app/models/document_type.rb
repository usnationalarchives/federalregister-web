class DocumentType
  attr_reader :type, :slug

  def initialize(type)
    @type = type
  end

  def identifier
    @identifier ||= case type
    when 'Rule', 'Rules'
      'rule'
    when 'Proposed Rule', 'Proposed Rules'
      'proposed_rule'
    when 'Notice', 'Notices'
      'notice'
    when 'Presidential Document', 'Presidential Documents',
      'Determination', 'Determinations',
      'Memorandum', 'Memorandums',
      'Executive Order', 'Executive Orders',
      'Proclamation', 'Proclamations',
      'Presidential Order', 'Presidential Orders'

      'presidential_document'
    when 'Uncategorized Document'
      'uncategorized'
    when 'Sunshine Act Document'
      'notice'
    when 'Correction', 'Corrections'
      'correction'
    when 'Administrative Order', 'Administrative Orders'
      # Only used by the Table of Contents when GPO groups
      # presdocs of type memorandum, determination, etc.
      'presidential_document'
    else
      message = "unknown document type #{type}"

      if Rails.env.development?
        raise message.inspect
      else
        Honeybadger.notify(
          error_class: "Unknown Document Type",
          error_message: message
        )
      end

      "uncategorized"
    end
  end

  def granule_class
    @granule_class ||= case type
      when "Rule", "Rules"
        "RULE"
      when "Proposed Rule", "Proposed Rules"
        "PRORULE"
      when "Notice"
        "NOTICE"
      when "Presidential Document"
        "PRESDOCU"
      when "Correction"
        "CORRECT"
      when "Uncategorized Document"
        "UNKNOWN"
      when "Sunshine Act Document"
        "SUNSHINE"
      end
  end

  def presdocu_granule_class(subtype)
    @presdocu_granule_class ||= case subtype
      when 'Determination'
        "DETERM"
      when 'Executive Order'
        'EXECORD'
      when 'Memorandum'
        'PRMEMO'
      when "Notice"
        "PRNOTICE"
      when 'Proclamation'
        'PROCLA'
      when 'Presidential Order'
        'PRORDER'
      end
  end

  def display_type
    type.
      split(" ").
      map(&:capitalize).
      join(" ")
  end

  def icon_wrapper_class(size=nil)
    "rule_type doc_#{identifier} #{size}"
  end

  def icon_class
    "icon-fr2 icon-doctype icon-fr2-#{identifier}"
  end

  # note: order matters here
  def self.document_types_for_search
    @types_for_search ||= [
      new("Notice"),
      new("Presidential Document"),
      new("Proposed Rule"),
      new("Rule"),
    ]
  end
end
