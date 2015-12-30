class Hyperlinker
  def self.perform(string, options={})
    new(options).perform(string)
  end

  attr_reader :options
  def initialize(options={})
    @options = options
  end

  def perform(string)
    modify_text_not_inside_anchor(string) do |text|
      processors.each do |processor|
        text = processor.perform(text, options)
      end

      text
    end
  end

  def processors
    [
      Hyperlinker::Url,
      Hyperlinker::Email,
      Hyperlinker::Citation,
    ]
  end

  def modify_text_not_inside_anchor(html)
    doc = Nokogiri::HTML::DocumentFragment.parse('<root>' + html.strip + '</root>')
    doc.xpath(".//text()[not(ancestor::a)]").each do |text_node|
      text = text_node.text.dup

      text = yield(text)

      # FIXME: this ugliness shouldn't be necessary, but seems to be
      if text != text_node.text
        dummy = text_node.add_previous_sibling(Nokogiri::XML::Node.new("dummy", doc))
        Nokogiri::XML::Document.parse("<text>#{text}</text>").xpath("/text/node()").each do |node|
          dummy.add_previous_sibling node
        end
        text_node.remove
        dummy.remove
      end
    end

    doc.xpath('./root').inner_html
  end
end
