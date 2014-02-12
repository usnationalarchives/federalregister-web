require File.dirname(__FILE__) + '/../spec_helper'

describe DocumentsController do
  context "GET short_document (/d/:document_number)" do
    describe "wants.html" do
      context "when document doesn't exist" do
        it "raises RecordNotFound" do
          expect{
            get :tiny_url, document_number: '2014-0000'
          }.to raise_error(FederalRegister::Client::RecordNotFound)
        end
      end

      context "when document exists" do
        let(:document) { OpenStruct.new(document_number: '2014-0000', html_url: "/documents/2014/01/01/2014-0000/test-document") }
        let(:get_tiny_url) { get :tiny_url, document_number: document.document_number }

        it "redirects to the full document page if the document exists" do
          expect(FederalRegister::Document).to receive(:find).with(document.document_number).and_return(document)
          expect(get_tiny_url).to redirect_to(document.html_url)
        end
      end
    end
  end
end
