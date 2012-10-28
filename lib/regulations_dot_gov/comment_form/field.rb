class RegulationsDotGov::CommentForm::Field
  def self.build(client, attributes, agency_id)
    klass = case attributes['uiControlType']
            when 'text'
              TextField
            when 'picklist'
              SelectField
            when 'combo'
              ComboField
            else
              raise "invalid type of #{attributes['type']} for field!"
            end

    klass.new(client, attributes, agency_id)
  end

  attr_reader :client, :attributes, :agency_id

  def initialize(client, attributes, agency_id)
    @client = client
    @attributes = attributes
    @agency_id = agency_id
  end

  def required?
    attributes["@required"] == "true"
  end

  def publically_viewable?
    attributes["@publicViewable"] == "true"
  end

  def name
    attributes["@attributeName"]
  end

  def label
    attributes["@attributeLabel"]
  end

  def hint
    attributes["tooltip"]
  end
end
