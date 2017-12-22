require 'spec_helper'

feature "FR Archives Integration", :no_ci do

  context "Documents search page" do
    #NOTE: Tests relate to the /documents/search/suggestions ESI, which powers the informational section at the top of the document search page

    scenario "The correct citation is returned", :vcr do
      visit '/documents/search/suggestions?conditions%5Bterm%5D=35+FR+118'
      expect(page).to have_content("35 FR 118 (Optimized Version")
    end

    scenario "A citation before the earliest archive issue is requested", :vcr do
      visit '/documents/search/suggestions?conditions%5Bterm%5D=1+FR+1'
      expect(page).to have_content("Older volumes may be available through")
    end

    scenario "A real citation that occurs after the archives", :vcr do
      visit '/documents/search/suggestions?conditions%5Bterm%5D=82+FR+60602'
      expect(page).to have_content("We've found the following documents")
    end
  end

  context "Citation#fr page" do

    scenario "Citation that references an issue before the archives", :vcr do
      visit '/citation/1-FR-1'
      expect(page).to have_content("No documents found")
      expect(page).to have_content("Older volumes may be available through a Federal Depository Library")
    end

    scenario "Citation that references an issue that falls within the archives", :vcr do
      visit '/citation/35-FR-117'
      expect(page).to have_text("An issue was located for citation")
      expect(page).to have_content("35 FR 117 Size-optimized Pages")
    end

    scenario "Citation that falls after the archives", :vcr do
      visit '/citation/82-FR-60602'
      expect(page).to have_content("Multiple documents found")
    end
  end

end
