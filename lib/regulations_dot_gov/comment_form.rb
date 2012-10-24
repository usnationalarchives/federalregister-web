class RegulationsDotGov::CommentForm
  attr_accessor :client, :attributes

  AGENCY_NAMES = YAML::load_file(Rails.root.join('data', 'regulations_dot_gov_agencies.yml'))

  def initialize(client, attributes)
    @client = client
    @attributes = attributes
  end

  def allow_attachments?
    attributes["showAttachment"] == true
  end

  def alternative_ways_to_comment
    attributes["document"]["docComments"]
  end

  def submit_by
    DateTime.parse(attributes["commentEndDate"])
  end

  def posting_guidelines
    attributes["postingGuidelines"]
  end

  def document_id
    attributes['document']['documentId']
  end

  def comments_open_at
    DateTime.parse(attributes['document']['commentStartDate'])
  end

  def comments_close_at
    DateTime.parse(attributes['document']['commentEndDate'])
  end

  def has_field?(name)
    fields.any?{|f| f.name == name.to_s}
  end

  def fields
    @fields ||= attributes["fieldList"]["field"].map do |field_attributes|
      Field.build(client, field_attributes, agency_id)
    end
  end

  def agency_name
    AGENCY_NAMES[agency_id] || agency_id
  end

  def agency_id
    attributes['document']['agencyId']
  end

  def text_fields
    fields.select{|x| x.is_a?(RegulationsDotGov::CommentForm::Field::TextField) }
  end

  def agency_participates_on_regulations_dot_gov?
    attributes["participating"]
  end
end
