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

    expect(html).to have_tag("span.preamble-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.preamble.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "Start Preamble"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.preamble-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.preamble.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "End Preamble"}
      end
    end
  end

  it "creates the proper elements for APPENDIX" do
    process <<-XML
      <APPENDIX>
        Some text nodes and other content nodes
      </APPENDIX>
    XML

    expect(html).to have_tag("span.appendix-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.appendix.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "Start Appendix"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.appendix-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.appendix.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "End Appendix"}
      end
    end
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
    end
  end

  it "creates the proper elements for LSTSUB" do
    process <<-XML
      <LSTSUB>
        Some text nodes and other content nodes
      </LSTSUB>
    XML

    expect(html).to have_tag("span.list-of-subjects-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.list-of-subjects.unprinted-element.icon-fr2-Molecular.cj-tooltip",
          with: {"data-tooltip" => "Start List of Subjects"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.list-of-subjects-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.list-of-subjects.unprinted-element.icon-fr2-Molecular.cj-tooltip",
          with: {"data-tooltip" => "End List of Subjects"}
      end
    end
  end

  it "creates the proper elements for PART" do
    process <<-XML
      <PART>
        Some text nodes and other content nodes
      </PART>
    XML

    expect(html).to have_tag("span.part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.part.unprinted-element.icon-fr2-book.cj-tooltip",
          with: {"data-tooltip" => "Start Part"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.part.unprinted-element.icon-fr2-book.cj-tooltip",
          with: {"data-tooltip" => "End Part"}
      end
    end
  end

  it "creates the proper elements for AMDPAR" do
    process <<-XML
      <AMDPAR>
        Some text nodes and other content nodes
      </AMDPAR>
    XML

    expect(html).to have_tag("span.amend-part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.amend-part.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "Start Amendment Part"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.amend-part-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.amend-part.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "End Amendment Part"}
      end
    end
  end

  it "creates the proper elements for AUTH" do
    process <<-XML
      <AUTH>
        Some text nodes and other content nodes
      </AUTH>
    XML

    expect(html).to have_tag("span.authority-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.authority.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "Start Authority"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.authority-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.authority.unprinted-element.icon-fr2-doc-generic.cj-tooltip",
          with: {"data-tooltip" => "End Authority"}
      end
    end
  end

  it "creates the proper elements for SUBPART" do
    process <<-XML
      <SUBPART>
        Some text nodes and other content nodes
      </SUBPART>
    XML

    expect(html).to have_tag("span.subpart-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.subpart.unprinted-element.icon-fr2-book.cj-tooltip",
          with: {"data-tooltip" => "Start Sub-Part"}
      end
    end

    #BB TODO: is this the right matcher here? check when online again
    expect(html).to match("Some text nodes and other content nodes")

    expect(html).to have_tag("span.subpart-wrapper.unprinted-element-wrapper") do
      with_tag "span.unprinted-element-border" do
        with_tag "span.subpart.unprinted-element.icon-fr2-book.cj-tooltip",
          with: {"data-tooltip" => "End Sub-Part"}
      end
    end
  end

end

