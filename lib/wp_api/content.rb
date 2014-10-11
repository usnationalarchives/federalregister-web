class WpApi::Content
  attr_reader :parent, :parent_id, :parent_title, :attributes
  def initialize(attributes)
    @attributes = attributes
  end

  def get(symbolized_attr)
    attr = String(symbolized_attr)
    attributes.keys.include?(attr) ? attributes[attr] : nil
  end

  def parent
    @parent ||= Parent.new(attributes['parent'])
  end

  def parent_id
    parent.id
  end

  def parent_title
    parent.title
  end

  class Parent
    attr_reader :id, :title, :attributes
    def initialize(attributes)
      @attributes = validate_attributes(attributes)
    end

    def title
      attributes['title']
    end

    def id
      attributes['ID']
    end

    private
    def validate_attributes(attributes)
      attributes.is_a?(Hash) ? attributes : {}
    end
  end
end
