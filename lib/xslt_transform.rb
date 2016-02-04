class XsltTransform
  def self.transform_xml(xml, stylesheet, options = {})
    xslt = Nokogiri::XSLT(
      File.read("#{Rails.root}/app/views/xslt/#{stylesheet}")
    )
    xslt.transform(Nokogiri::XML(xml), options.map{|k,v| [k,v.inspect]}.flatten)
  end

  def self.standardized_html(doc, options={})
    indent_text = options.fetch(:indent_text) { " " }
    indent = options.fetch(:indent) { 2 }

    xml = Nokogiri::XML(
      normalize_whitespace("<root>#{doc}</root>"),
      &:noblanks
    )

    xml.encoding = "UTF-8"
    xml.to_xhtml(indent_text: indent_text, indent: indent).
      gsub(/^<\/?root>/,'')
  end

  def self.xml_for_development(document)
    document_path = document.full_text_xml_url.split('xml').last

    File.read(
      File.join(Rails.root, '..', 'federalregister-api-core/data/xml', "#{document_path}xml")
    )
  end

  private

  def self.normalize_whitespace(doc)
    doc.gsub(/\s+/, ' ')
  end
end

Nokogiri::XSLT.register "http://federalregister.gov/functions", XsltFunctions
