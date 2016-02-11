class WpApi::Content
  attr_reader :parent, :attributes

  def initialize(attributes)
    @attributes = attributes
  end

  WHITELISTED_ATTRIBUTES = [
    'link',
  ]

  WHITELISTED_ATTRIBUTES.each do |attribute|
    define_method(attribute) { attributes[attribute] }
  end

  def get(symbolized_attr)
    attr = String(symbolized_attr)
    attributes.keys.include?(attr) ? attributes[attr] : nil
  end

  def id
    attributes['id']
  end

  def title
    attributes['title'] ? attributes['title']['rendered'] : nil
  end

  def formatted_title
    if title
      clean_content(title).html_safe
    else
      "No title provided."
    end
  end

  def content
    attributes['content'] ? attributes['content']['rendered'] : nil
  end

  def formatted_content
    clean_content(content).html_safe if content
  end

  def excerpt
    attributes['excerpt'] ? attributes['excerpt']['rendered'] : nil
  end

  def formatted_excerpt
    #binding.pry
    if excerpt
      clean_content(excerpt).html_safe
    else
      "No excerpt available."
    end
  end

  def parent
    return nil if attributes['parent'] == 0

    @parent ||= WpApi::Client.get_page(id: attributes['parent'])
  end

  def author
    @author ||= WpApi::Author.find(attributes['author'])
  end

  def categories
    categories = []

    attributes['categories'].map do |category_id|
      categories << WpApi::Category.find(category_id)
    end

    categories.compact
  end

  def modified
    attributes['modified'].try(:to_date)
  end

  private

  def clean_content(node)
    CGI.unescapeHTML(
      node.
        gsub(/&nbsp;/, ' ').
        strip
    )
  end
end
