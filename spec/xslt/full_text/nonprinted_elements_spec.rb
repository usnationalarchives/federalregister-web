require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::NonPrintedElements" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates the proper elements for APPENDIX in a REGTEXT block" do
    process <<-XML
      <REGTEXT>
        <APPENDIX>
          Some text nodes and other content nodes
        </APPENDIX>
      </REGTEXT>
    XML

    expect_equivalent <<-HTML
      <div class="appendix">
        Some text nodes and other content nodes
      </div>
    HTML
  end

  it "does not create elements for APPENDIX not in a REGTEXT block" do
    process <<-XML
      <APPENDIX>
        Some text nodes and other content nodes
      </APPENDIX>
    XML

    expect_equivalent <<-HTML
      Some text nodes and other content nodes
    HTML
  end

  it "creates the proper elements for SIG" do
    process <<-XML
      <SIG>
        Some text nodes and other content nodes
      </SIG>
    XML

    expect_equivalent <<-HTML
      <div class="signature">
        Some text nodes and other content nodes
      </div>
    HTML
  end

  it "creates the proper elements for SUPLINF" do
    process <<-XML
      <SUPLINF>
        Some text nodes and other content nodes
      </SUPLINF>
    XML

    expect_equivalent <<-HTML
      <div class="supplemental-info">
        Some text nodes and other content nodes
      </div>
    HTML
  end

  it "creates the proper elements for LSTSUB" do
    process <<-XML
      <LSTSUB>
        Some text nodes and other content nodes
      </LSTSUB>
    XML

    expect_equivalent <<-HTML
      <div class="list-of-subjects">
        Some text nodes and other content nodes
      </div>
    HTML
  end

  it "creates the proper elements for PART" do
    process <<-XML
      <PART>
        Some text nodes and other content nodes
      </PART>
    XML

    expect_equivalent <<-HTML
      <div class="part">
        Some text nodes and other content nodes
      </div>
    HTML
  end

  it "creates the proper elements for AMDPAR" do
    process <<-XML
      <AMDPAR>
        Some text nodes and other content nodes
      </AMDPAR>
    XML

    expect_equivalent <<-HTML
      <p class="amendment-part" id="p-amd-1">
        Some text nodes and other content nodes
      </p>
    HTML
  end

  it "creates the proper elements for AUTH" do
    process <<-XML
      <AUTH>
        Some text nodes and other content nodes
      </AUTH>
    XML

    expect_equivalent <<-HTML
      <p class="authority" id="p-1" data-page="1000">
        Some text nodes and other content nodes
      </p>
    HTML
  end

  it "creates the proper elements for SUBPART" do
    process <<-XML
      <SUBPART>
        Some text nodes and other content nodes
      </SUBPART>
    XML

    expect_equivalent <<-HTML
      <div class="subpart">
        Some text nodes and other content nodes
      </div>
    HTML
  end

end
