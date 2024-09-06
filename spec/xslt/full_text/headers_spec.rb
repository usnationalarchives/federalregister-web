require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Headers" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "basic header creation" do
    it "HED becomes h1" do
      process <<-XML
        <HD SOURCE="HED">Header 1</HD>
      XML

      expect_equivalent <<-HTML
        <h1 id="h-1">Header 1</h1>
      HTML
    end

    it "HD1 becomes h2" do
      process <<-XML
        <HD SOURCE="HD1">Header 2</HD>
      XML

      expect_equivalent <<-HTML
        <h2 id="h-1">Header 2</h2>
      HTML
    end

    it "HD2 becomes h3" do
      process <<-XML
        <HD SOURCE="HD2">Header 3</HD>
      XML

      expect_equivalent <<-HTML
        <h3 id="h-1">Header 3</h3>
      HTML
    end

    it "HD3 becomes h4" do
      process <<-XML
        <HD SOURCE="HD3">Header 4</HD>
      XML

      expect_equivalent <<-HTML
        <h4 id="h-1">Header 4</h4>
      HTML
    end

    it "HD4 becomes h5" do
      process <<-XML
        <HD SOURCE="HD4">Header 5</HD>
      XML

      expect_equivalent <<-HTML
        <h5 id="h-1">Header 5</h5>
      HTML
    end

    it "multiple headers get the incrementing id's so they can be targeted" do
      process <<-XML
        <HD SOURCE="HED">SUPPLEMENTARY INFORMATION:</HD>
        <HD SOURCE="HD1">Background</HD>
        <HD SOURCE="HD1">Specific Changes Made by This Rule</HD>
        <HD SOURCE="HD2">Creation of License Exception Support for the Cuban People (SCP)</HD>
        <HD SOURCE="HD3">Expansion of License Exception Consumer Communications Devices (CCD)</HD>
        <HD SOURCE="HD1">Export Administration Act</HD>
        <HD SOURCE="HD4">Expansion of License Exception Gift Parcels and Humanitarian Donations (GFT)</HD>
      XML

      expect_equivalent <<-HTML
        <h1 id="h-1">SUPPLEMENTARY INFORMATION:</h1>
        <h2 id="h-2">Background</h2>
        <h2 id="h-3">Specific Changes Made by This Rule</h2>
        <h3 id="h-4">Creation of License Exception Support for the Cuban People (SCP)</h3>
        <h4 id="h-5">Expansion of License Exception Consumer Communications Devices (CCD)</h4>
        <h2 id="h-6">Export Administration Act</h2>
        <h5 id="h-7">Expansion of License Exception Gift Parcels and Humanitarian Donations (GFT)</h5>
      HTML
    end
  end
end
