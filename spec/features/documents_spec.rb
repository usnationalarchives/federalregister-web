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

    expect(page).to have_metadata_link_with_content('.metadata', documents_path(document.publication_date), document.publication_date)

    expect(page).to have_metadata_content('.share .clip_for_later form.add_to_clipboard', nil, visible: false)
    expect(page).to have_metadata_content('.share .clip_for_later #clipping-actions')
  end
end
