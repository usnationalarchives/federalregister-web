class RegulationsDotGov::CommentForm::Field
  def self.build(client, attributes)
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

    klass.new(client, attributes)
  end

  attr_reader :client, :attributes

  def initialize(client, attributes)
    @client = client
    @attributes = attributes
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
