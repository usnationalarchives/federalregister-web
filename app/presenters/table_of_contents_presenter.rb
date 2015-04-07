class TableOfContentsPresenter
  attr_reader :table_of_contents_data

  def initialize(date=nil)
    url = 'http://localhost:3000/documents/table_of_contents/json/2015/02/25.json'
    #TODO: Dynamically generate url using Settings.federal_register.local, etc.
    @table_of_contents_data = HTTParty.get(url)
  end

  def lookup_document(doc_number)
    get_documents.results.find{|doc| doc.document_number == doc_number}
  end

  def agencies
    table_of_contents_data["agencies"]
  end

  def documents
    get_documents
  end

  def render_a_partial
    render :partial => "table_of_contents_doc_details", locals: {document: "Stubbed Document" , title: "Stubbed Out Title"}
  end

  def test_doc_objects
    agencies[2]["document_categories"].first["documents"]
  end

  def display_level(docs=test_doc_objects, level=1)
    docs.group_by{|doc| doc["subject_#{level}"]}.each do |subject_heading, docs|
      indent = "  " * level

      finished_docs, nested_docs = docs.partition{|x| x["subject_#{level+1}"].nil?}

      puts indent + subject_heading if subject_heading
      finished_docs.each do |doc|

        puts indent + "doc=" + doc["document_numbers"].first #render partial here
      end

      unless nested_docs.empty?
        display_level(nested_docs, level+1) if level < 3
      end
    end
  end

  private

  def get_documents
    @documents ||= Document.search(QueryConditions.toc_conditions("February 25, 2015".to_date))
  end

end


# {"document_categories"=>[{"name"=>"NOTICES", "documents"=>[{"subject_1"=>"Charter Renewals:", "subject_2"=>"Global Development Council,", "document_numbers"=>["2015-03807"]}]}]}