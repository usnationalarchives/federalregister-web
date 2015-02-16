module XsltTestHelper
  require 'nokogiri'
  require 'xslt_transform'
  require 'action_controller'
  require 'pry'

  def process(xml, type="RULE")
    @html = XsltTransform.transform_xml(
      "<#{type}>#{xml}</#{type}>",
      @template,
      'first_page' => "1000"
    )
  end

  def expect_equivalent(expected_output)
    expect(
      XsltTransform.standardized_html(@html.to_xml)
    ).to eql(
      XsltTransform.standardized_html(expected_output)
    )
  end
end

# stub rails root so we can run tests without loading the whole environment
unless Module.const_defined?(:Rails)
  module Rails
    def self.root
      File.expand_path(File.join(__FILE__, '../../../'))
    end
  end
end
