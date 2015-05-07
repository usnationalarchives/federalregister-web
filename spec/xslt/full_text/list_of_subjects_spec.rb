require './spec/support/xslt_test_helper'
include XsltTestHelper

describe "XSLT::FullText::ListOfSubjects" do
  before :all do
    @template = "matchers/full_text.html.xslt"
  end

  it "creates list items for each term in the subject list" do
    process <<-XML
      <LSTSUB>
        <HD SOURCE="HED">List of Subjects in 9 CFR Part 78</HD>
        <P>Animal diseases, Bison, Cattle.</P>
      </LSTSUB>
    XML

    # header
    expect(html).to have_tag("h2.list-of-subjects") do
      with_text "List of Subjects in 9 CFR Part 78"
    end

    # list items
    expect(html).to have_tag("div.subject-list") do
      with_tag("li a", with: {href: "/topics/animal-diseases"}) do
        with_text "Animal diseases"
      end
    end
    expect(html).to have_tag("div.subject-list") do
      with_tag("li a", with: {href: "/topics/bison"}) do
        with_text "Bison"
      end
    end
    expect(html).to have_tag("div.subject-list") do
      with_tag("li a", with: {href: "/topics/cattle"}) do
        with_text "Cattle"
      end
    end
  end
end
