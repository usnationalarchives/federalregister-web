module XsltTestHelper
  require 'nokogiri'
  require 'gpo_images/image_identifier_normalizer'
  require 'xslt_functions'
  require 'xslt_transform'
  require 'action_controller'
  require 'pry'
  require 'spec_helper'

  def process(xml, type="RULE")
    default_xslt_vars = {
      'first_page' => "1000",
      'document_number' => '2014-12345',
      'publication_date' => '2014-10-15',
      'images' => ""
    }
    @xslt_vars ||= {}

    @transformed = XsltTransform.transform_xml(
      "<#{type}>#{xml}</#{type}>",
      @template,
      default_xslt_vars.merge!(@xslt_vars)
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
