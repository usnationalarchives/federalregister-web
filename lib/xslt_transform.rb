class XsltTransform
  def self.transform_xml(xml, stylesheet, options = {})
    xslt = Nokogiri::XSLT(
      File.read("#{RAILS_ROOT}/app/views/xslt/#{stylesheet}")
    )
    xslt.transform(Nokogiri::XML(xml), options.to_a.flatten)
  end

  def self.standardized_html(doc, options={})
    indent_text = options.fetch(:indent_text) { " " }
    indent = options.fetch(:indent) { 2 }

    Nokogiri::XML(normalize_whitespace(doc),&:noblanks).
      to_html(indent_text: indent_text, indent: indent)
  end

  private

  def self.normalize_whitespace(doc)
    doc.gsub(/\s+/, ' ')
  end
end
