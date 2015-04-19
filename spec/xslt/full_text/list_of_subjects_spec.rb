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
        <P>Animal diseases, Bison, Cattle, Transportation.</P>
      </LSTSUB>
    XML

    expect_equivalent <<-HTML
      <h2 id="h-1" class="list-of-subjects">List of Subjects in 9 CFR Part 78</h2>
      <div class="subject-list">
        <ul>
          <li><a href="/topics/animal-diseases">Animal diseases</a></li>
          <li><a href="/topics/bison">Bison</a></li>
          <li><a href="/topics/cattle">Cattle</a></li>
          <li><a href="/topics/transportation">Transportation</a></li>
        </ul>
      </div>
    HTML
  end
end
