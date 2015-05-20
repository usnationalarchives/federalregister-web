module XsltTestHelper
  require 'nokogiri'
  require 'xslt_transform'
  require 'action_controller'
  require 'pry'
  require 'spec_helper'

  def process(xml, type="RULE")
    @transformed = XsltTransform.transform_xml(
      "<#{type}>#{xml}</#{type}>",
      @template,
      'first_page' => "1000",
      'document_number' => '2014-12345',
      'publication_date' => '2014-10-15',
      'image_identifiers' => ["EP01MY09.019","EP01MY09.020"],
      'image_base_url' => 'https://s3.amazonaws.com/images.federalregister.gov/:identifier/:style.png'
    )
  end

  def expect_equivalent(expected_output)
    expect(
      XsltTransform.standardized_html(html)
    ).to eql(
      XsltTransform.standardized_html(expected_output)
    )
  end

  def html
    @transformed.to_xml
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
