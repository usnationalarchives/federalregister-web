class WpApi::Content
  attr_reader :parent, :parent_id, :parent_title, :attributes
  def initialize(attributes)
    @attributes = attributes
  end

  WHITELISTED_ATTRIBUTES = [
    'title',
    'ID',
    'link',
    'content',
    'excerpt',
  ]

  WHITELISTED_ATTRIBUTES.each do |attribute|
    define_method(attribute) { attributes[attribute] }
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

  def author
    @author ||= Author.new(attributes['author'])
  end

  def modified
    attributes['modified'].to_date
  end

  class Author
    attr_reader :id, :title, :attributes
    def initialize(attributes)
      @attributes = validate_attributes(attributes)
    end

    WHITELISTED_ATTRIBUTES = [
      'ID',
      'username',
      'name',
      'first_name',
      'last_name',
      'nickname',
      'slug',
      'URL',
      'avatar',
      'description',
      'registered',
      'meta',
    ]

    WHITELISTED_ATTRIBUTES.each do |attribute|
      define_method(attribute) { attributes[attribute] }
    end

    private
    def validate_attributes(attributes)
      attributes.is_a?(Hash) ? attributes : {}
    end
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
