require 'nokogiri'

class IconSpriteGenerator

  def self.transform_xml(xml_input, icon_id)
    doc = Nokogiri::XML(xml_input)
    symbol_id = doc.at('g')['id']
    viewBox = doc.at('svg')['viewBox']
    
    path_data = doc.at('path')['d']
    
    symbol = Nokogiri::XML::Node.new('symbol', doc)
    symbol['id'] = symbol_id
    symbol['viewBox'] = viewBox
    
    path = Nokogiri::XML::Node.new('path', doc)
    path['style'] = doc.at('path')['style']
    path['d'] = path_data
    
    symbol << path
    
    symbol.to_xml
  end

end
