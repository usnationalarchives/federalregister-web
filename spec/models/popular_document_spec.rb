require 'spec_helper'

describe PopularDocument do

  describe ".popular" do
    let(:fake_comment_form) { RegulationsDotGov::CommentForm.new(nil, {'fieldList' => []}) }

    it "returns a list of documents scored in ascending order" do
      doc_response = FederalRegister::ResultSet.new(
        {'results' => [
            {'document_number' => 'foo', 'page_views' => {'count' => '1'}},
            {'document_number' => 'bar', 'page_views' => {'count' => '2'}}
          ] },
        Document
      )
      FactoryGirl.create(:comment, document_number: 'foo', comment_form: fake_comment_form)
      FactoryGirl.create(:comment, document_number: 'bar', comment_form: fake_comment_form)

      allow(Document).to receive(:search).and_return(doc_response)

      popular_documents = PopularDocument.popular
      expect(popular_documents.count).to eq(2)
      expect(popular_documents.first.document_number).to eq('foo')
      expect(popular_documents.last.document_number).to eq('bar')
    end

    it "if a document has no comments, it is omitted" do
      doc_response = FederalRegister::ResultSet.new(
        {'results' => [{'document_number' => 'foo', 'page_views' => {'count' => '1'}}] },
        Document
      )
      allow(Document).to receive(:search).and_return(doc_response)

      result = PopularDocument.popular.count

      expect(result).to eq(0)
    end

    it "if a comment is missing an associated document, the method still returns" do
      doc_response = FederalRegister::ResultSet.new(
        {'results' => [] },
        Document
      )
      allow(Document).to receive(:search).and_return(doc_response)
      FactoryGirl.create(:comment, document_number: 'foo', comment_form: fake_comment_form)

      result = PopularDocument.popular.count

      expect(result).to eq(0)
    end

  end

end
