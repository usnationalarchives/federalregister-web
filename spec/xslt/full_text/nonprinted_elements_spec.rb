require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::NonPrintedElements" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates the proper elements for PREAMB" do
    process <<-XML
      <PREAMB>
        Some text nodes and other content nodes
      </PREAMB>
    XML

    expect_equivalent <<-HTML
      <span class="unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
          <span class="preamble unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip"
            data-tooltip="Start Preamble"> </span>
        <span class="unprinted-element-border"></span>
      </span>

      Some text nodes and other content nodes

      <span class="unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
          <span class="preamble unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip"
            data-tooltip="End Preamble"> </span>
        <span class="unprinted-element-border"></span>
      </span>
    HTML
  end

  it "creates the proper elements for SIG" do
    process <<-XML
      <SIG>
        Some text nodes and other content nodes
      </SIG>
    XML

    expect(html).to have_tag("span.signature-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.signature.unprinted-element.icon-fr2-pen.cj-tooltip",
          with: {"data-tooltip" => "Start Signature"}
      end
    end

    expect(html).to have_tag("div.signature") do
      with_text /Some text nodes and other content nodes/
    end

    expect(html).to have_tag("span.signature-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.signature.unprinted-element.icon-fr2-pen.cj-tooltip",
          with: {"data-tooltip" => "End Signature"}
      end
    end
  end

  it "creates the proper elements for SUPLINF" do
    process <<-XML
      <SUPLINF>
        Some text nodes and other content nodes
      </SUPLINF>
    XML

    expect(html).to have_tag("span.supplemental-info-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.supplemental-info.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "Start Supplemental Information"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.supplemental-info-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.supplemental-info.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "End Supplemental Information"}
      end
    end  end
end

