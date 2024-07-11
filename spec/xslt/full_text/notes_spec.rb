require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::Notes" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "with standard structure" do
    before :all do
      process <<-XML
        <EDNOTE>
          <HD SOURCE="HED">Editorial Note:</HD>
          <P>
          This document has an editorial note
          </P>
        </EDNOTE>
      XML
    end

    it "creates the expected editorial note structure" do
      expect_equivalent <<-HTML
        <div class="editorial-note">
          <div class="fr-box fr-box-published-alt no-footer">
            <div class="fr-seal-block fr-seal-block-header">
              <div class="fr-seal-content">
                <span class="h6"> Editorial Note </span>
              </div>
            </div>
            <div class="content-block ">
              <h4 class="inline-header">Editorial Note:</h4>
              <p class="inline-paragraph">
                This document has an editorial note
              </p>
            </div>
          </div>
        </div>
      HTML
    end
  end

  context "with @TYPE='POSTPUB'" do
    before :all do
      process <<-XML
        <EDNOTE TYPE="POSTPUB">
          <HD SOURCE="HED">Editorial Note:</HD>
          <P>
          This document has an editorial note
          </P>
        </EDNOTE>
      XML
    end

    it "creates the expected enhanced content editorial note structure" do
      expect_equivalent <<-HTML
        <div class="editorial-note">
          <div class="fr-box fr-box-enhanced no-footer">
            <div class="fr-seal-block fr-seal-block-header">
              <div class="fr-seal-content">
                <span class="h6">Enhanced Content - Editorial Note </span>
              </div>
            </div>
            <div class="content-block ">
              <h4 class="inline-header">Editorial Note:</h4>
              <p class="inline-paragraph">
                This document has an editorial note
              </p>
            </div>
          </div>
        </div>
      HTML
    end
  end
end
