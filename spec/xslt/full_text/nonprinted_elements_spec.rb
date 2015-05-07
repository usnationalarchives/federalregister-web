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

    expect_equivalent <<-HTML
      <span class="unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
          <span class="signature unprinted-element icon-fr2 icon-fr2-pen cj-tooltip"
            data-tooltip="Start Signature"> </span>
        <span class="unprinted-element-border"></span>
      </span>

      <div class="signature">
        Some text nodes and other content nodes
      </div>

      <span class="unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
          <span class="signature unprinted-element icon-fr2 icon-fr2-pen cj-tooltip"
            data-tooltip="End Signature"> </span>
        <span class="unprinted-element-border"></span>
      </span>
    HTML
  end

  it "creates the proper elements for SUPLINF" do
    process <<-XML
      <SUPLINF>
        Some text nodes and other content nodes
      </SUPLINF>
    XML

    expect_equivalent <<-HTML
      <span class="unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
          <span class="supplemental-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip"
            data-tooltip="Start Supplemental Information"> </span>
        <span class="unprinted-element-border"></span>
      </span>

      Some text nodes and other content nodes

      <span class="unprinted-element-wrapper">
        <span class="unprinted-element-border"></span>
          <span class="supplemental-info unprinted-element icon-fr2 icon-fr2-doc-generic cj-tooltip"
            data-tooltip="End Supplemental Information"> </span>
        <span class="unprinted-element-border"></span>
      </span>
    HTML
  end
end

