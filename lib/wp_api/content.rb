class WpApi::Content
  attr_reader :parent, :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  WHITELISTED_ATTRIBUTES = [
    'title',
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

  def id
    attributes['ID']
  end

  def formatted_title
    if title
      title.html_safe
    else
      "No title provided."
    end
  end

  def formatted_content
    content.html_safe if content
  end

  def formatted_excerpt
    if excerpt
      excerpt.html_safe
    else
      "No description available."
    end
  end

  def parent
    @parent ||= Parent.new(attributes['parent'])
  end

  def author
    @author ||= Author.new(attributes['author'])
  end

  def categories
    categories = []
    attributes['terms']['category'].each do |category|
      categories << category['slug']
    end
    categories
  end

  def modified
    attributes['modified'].try(:to_date)
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
      define_method(attribute.downcase) { attributes[attribute] }
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

    def slug
      attributes['slug']
    end

    private
    def validate_attributes(attributes)
      attributes.is_a?(Hash) ? attributes : {}
    end
  end
end
