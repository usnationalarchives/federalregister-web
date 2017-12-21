require 'spec_helper'

feature "FR Archives Integration", :no_ci do
  #NOTE: Tests /documents/search/suggestions ESI which powers the top informational section of the document search page at /documents/search?conditions%5Bterm%5D=20+FR+60602

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
