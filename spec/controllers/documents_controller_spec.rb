require File.dirname(__FILE__) + '/../spec_helper'

describe DocumentsController do
  context "GET short_document (/d/:document_number)", :no_ci do
    let(:document_number) { '2035-0001'}
    let(:document_html_url_base) { '/documents/2035/01/01/2035-0001'}

    describe "wants.html" do
      context "when document doesn't exist" do
        it "raises RecordNotFound" do
          expect{
            get :tiny_url, document_number: document_number
          }.to raise_error(FederalRegister::Client::RecordNotFound)
        end

        context "but public inspection document exists" do
          let(:pi_document) {
            OpenStruct.new(
              document_number: document_number,
              html_url: "#{document_html_url_base}/test-pi-document"
            )
          }

          let(:get_tiny_url) {
            get :tiny_url, document_number: pi_document.document_number
          }

          it "redirects to the public inspection page (document page)" do
            expect(
              FederalRegister::PublicInspectionDocument
            ).to receive(:find).
              with(pi_document.document_number).
              and_return(pi_document)

            expect(get_tiny_url).to redirect_to(pi_document.html_url)
          end
        end
      end

      context "when document exists" do
        let(:document) {
          OpenStruct.new(
            document_number: document_number,
            html_url: "#{document_html_url_base}/test-document"
          )
        }

        let(:get_tiny_url) {
          get :tiny_url, document_number: document.document_number
        }

        it "redirects to the full document page if the document exists" do
          expect(
            FederalRegister::Document
          ).to receive(:find).
            with(document.document_number).
            and_return(document)

          expect(get_tiny_url).to redirect_to(document.html_url)
        end
      end
    end
  end
end
