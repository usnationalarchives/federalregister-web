require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::ListOfSubjects" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  context "single CFR part affected" do
    it "creates list items for each term in the subject list" do
      process <<-XML
        <LSTSUB>
          <HD SOURCE="HED">List of Subjects in 9 CFR Part 78</HD>
          <P>Animal diseases, Bison, Cattle.</P>
        </LSTSUB>
      XML

      # header
      expect(html).to have_tag("h1") do
        with_text "List of Subjects in 9 CFR Part 78"
      end

      # list items
      expect(html).to have_tag("ul.subject-list") do
        with_tag("li") do
          with_text "Animal diseases"
        end

        with_tag("li") do
          with_text "Bison"
        end

        with_tag("li") do
          with_text "Cattle"
        end
      end
    end
  end

  context "multiple CFR pars affected" do
    it "creates a header for each CFR part" do
      process <<-XML
        <LSTSUB>
          <HD SOURCE="HED">List of Subjects</HD>
          <CFR>40 CFR Part 52</CFR>
          <P>Environmental protectven'ion, Air pollution control, Incorporation by reference, Intergovernmental relations, Nitrogen dioxide, Ozone, Reporting and recordkeeping requirements, Volatile organic compounds.</P>
          <CFR>40 CFR Part 81</CFR>
          <P>Environmental protection, Air pollution control.</P>
        </LSTSUB>
      XML

      expect(html).to have_tag('h3.cfr-subjects#los-40-CFR-Part-52') do
        with_text "40 CFR Part 52"
      end
      expect(html).to have_tag('h3.cfr-subjects#los-40-CFR-Part-81') do
        with_text "40 CFR Part 81"
      end
    end
  end
end
