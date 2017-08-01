# encoding: utf-8
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

    it "creates properly ignores empty P tags" do
      process <<-XML
        <LSTSUB>
          <HD SOURCE="HED">List of Subjects in 9 CFR Part 78</HD>
          <P/>
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

      expect(html).to have_tag('h3.cfr-subjects#los-cfr-1') do
        with_text "40 CFR Part 52"
      end
      expect(html).to have_tag('h3.cfr-subjects#los-cfr-2') do
        with_text "40 CFR Part 81"
      end
    end

    it "creates a header for each CFR part when the part is a link in the XML (with and without additional text)" do
      process <<-XML
        <LSTSUB>
          <HD SOURCE="HED">List of Subjects</HD>
          <CFR>
            <a class="cfr external" href="/select-citation/2016/05/07/24-CFR-1000">24 CFR Part 1000</a>
          </CFR>
          <P>
            Aged, Community development block grants, Grant programs—housing and community development, Grant programs—Indians, Indians, Individuals with disabilities, Public housing, Reporting and recordkeeping requirements.
          </P>
          <CFR>
            <a class="cfr external" href="/select-citation/2016/05/07/24-CFR-1003">24 CFR Part 1003</a>.1234
          </CFR>
          <P>
            Alaska, Community development block grants, Grant programs—housing and community development, Grant programs—Indians, Indians, Reporting and recordkeeping requirements.
          </P>
        </LSTSUB>
      XML

      expect(html).to have_tag('h3.cfr-subjects#los-cfr-1') do
        with_tag("a.cfr.external", with: {href: "/select-citation/2016/05/07/24-CFR-1000"}) do
          with_text "24 CFR Part 1000"
        end
      end
      expect(html).to have_tag('h3.cfr-subjects#los-cfr-2') do
        with_text /\.1234/
        with_tag("a.cfr.external", with: {href: "/select-citation/2016/05/07/24-CFR-1003"}) do
          with_text "24 CFR Part 1003"
        end
      end
    end

    it "properly increments header ids when there are more than one list of subjects or outside CFR nodes" do
      process <<-XML
        <LSTSUB>
          <HD SOURCE="HED">List of Subjects</HD>
          <CFR>24 CFR Part 1000</CFR>
          <P>Aged</P>
        </LSTSUB>

        <CFR>I don't belong</CFR>

        <LSTSUB>
          <HD SOURCE="HED">Extra List of Subjects</HD>
          <CFR>24 CFR Part 1003</CFR>
          <P>Alaska</P>
        </LSTSUB>
      XML

      expect(html).to have_tag('h3.cfr-subjects#los-cfr-1')
      expect(html).to have_tag('h3.cfr-subjects#los-cfr-2')
      expect(html).to_not have_tag('h3.cfr-subjects#los-cfr-3')
    end
  end
end
