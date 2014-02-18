require 'spec_helper'

feature "Document" do
  let(:document) do
    DocumentDecorator.decorate(FederalRegister::Document.find("4242-4242"))
  end

  scenario "visiting a document page", :vcr do
    visit document.html_url

    # meta tags
    expect(page).to have_meta(:title, document.title)
    expect(page).to have_meta(:description, document.abstract)


    # document type bar
    expect(page).to have_selector("div.title", text: document.type)


    # metadata content area
    expect(page).to have_metadata_content('h1', document.title)

    document.agencies.each do |agency|
      expect(page).to have_metadata_link_with_content('.metadata', agency.url, agency.name)
    end

    expect(page).to have_metadata_link_with_content('.metadata', documents_path(document.publication_date), document.formatted_publication_date)

    expect(page).to have_metadata_content('.share .clip_for_later form.add_to_clipboard', nil, visible: false)
    expect(page).to have_metadata_content('.share .clip_for_later #clipping-actions')
  end

  context "document page document details" do
    context "standard document" do
      scenario "it displays metadata properly", :vcr do
        visit document.html_url

        # document details box
        expect(page).to have_selector('div.fr-box.fr-box-small.fr-box-official-alt')

        # metadata
        expect(page).to have_document_details_content('dt', 'Publication Date')
        expect(page).to have_document_details_link_with_content('dd', documents_path(document.publication_date), document.formal_publication_date)

        expect(page).to have_document_details_content('dt', 'Agency:')
        expect(page).to have_document_details_link_with_content('dd', document.agencies.first.url, document.agencies.first.name)

        expect(page).to have_document_details_content('dt', 'Dates:')
        expect(page).to have_document_details_content('dd', document.dates)

        expect(page).to have_document_details_content('dt', 'Effective Date:')
        expect(page).to have_document_details_content('dd', document.formatted_effective_date)

        expect(page).to have_document_details_content('dt', 'Comments Close:')
        expect(page).to have_document_details_content('dd', document.comments_close_on)

        expect(page).to have_document_details_content('dt', 'Action:')
        expect(page).to have_document_details_content('dd', document.action)

        expect(page).to have_document_details_content('dt', 'Document Citation:')
        expect(page).to have_document_details_content('dd', "#{document.volume} FR #{document.start_page}")

        expect(page).to have_document_details_content('dt', 'Page:')
        expect(page).to have_document_details_content('dd', "#{document.start_page}-#{document.end_page} (#{document.human_length} pages)")

        expect(page).to have_document_details_content('dt', 'CFR:')
        expect(page).to have_document_details_link_with_content('dd', document.cfr_references.first["citation_url"], "#{document.cfr_references.first['title']} CFR #{document.cfr_references.first['part']}")

        expect(page).to have_document_details_content('dt', 'Agency/Docket Numbers:')
        document.docket_ids.each do |docket_id|
          expect(page).to have_document_details_content('dd', docket_id)
        end

        expect(page).to have_document_details_content('dt', 'RIN:')
        document.regulation_id_numbers.each do |rin|
          expect(page).to have_document_details_link_with_content('dd', document.regulation_id_number_info[rin]["html_url"], rin)
        end

        expect(page).to have_document_details_content('dt', 'Document Number:')
        expect(page).to have_document_details_content('dd', document.document_number)

        expect(page).to have_document_details_content('dt', 'Shorter URL:')
        expect(page).to have_document_details_link_with_content('dd', short_document_url(document).gsub('example.com', 'fr2.local:8081'), short_document_url(document).gsub('example.com', 'fr2.local:8081'))
        expect(page).to have_document_details_content('dd .clippy_wrapper', "")
      end
    end

    context "presidential document" do
      let(:document) do
        DocumentDecorator.decorate(FederalRegister::Document.find("4545-4545"))
      end

      scenario "it displays metadata properly", :vcr do
        visit document.html_url

        # document details box
        expect(page).to have_selector('div.fr-box.fr-box-small.fr-box-official-alt')

        # metadata
        expect(page).to have_document_details_content('dt', 'Presidential Document Type:')
        expect(page).to have_document_details_content('dd', document.subtype)

        expect(page).to have_document_details_content('dt', 'E.O. Citation:')
        expect(page).to have_document_details_content('dd', "E.O. #{document.executive_order_number} of #{document.shorter_ordinal_signing_date}")

        expect(page).to have_document_details_content('dt', 'E.O. Notes:')
        expect(page).to have_document_details_content('dd', document.executive_order_notes)
      end
    end
  end
end
