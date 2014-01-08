require 'spec_helper'

feature "Creating clippings" do
  context "a non-logged in user" do
    scenario "should show as clipped on the page, in the user_utils area, and be available in my clippings", :js do
      visit '/articles/2014/01/01/4242-4242/test-document'

      # no documents should be clipped
      expect(page).to have_user_util("#doc_count", 0)
      expect(page).to_not have_clipping_action('#add-to-folder .icon-fr2-flag.clipped', '')

      clip_current_document

      # one document should show as clipped
      expect(page).to have_clipping_action('#add-to-folder .icon-fr2-flag.clipped', '')
      expect(page).to have_user_util("#doc_count", 1)

      click_nav_item("My FR", "My Clipboard")

      # warning message and clipped document should be visible
      expect(page).to have_selector('.warning.message p', 'These clippings are not permanently saved. Please sign in or sign up to save them permanently.')
      expect(page).to have_clipping_with_title('Test Document')
    end
  end

  context "a non-logged in user who signs up" do
    scenario "should show as clipped on the page, in the user_utils area, and be available in my clippings once signed up", :js do
      visit '/articles/2014/01/01/4242-4242/test-document'

      clip_current_document
      click_user_util_item('Sign up')

      # create user
      user = FactoryGirl.build(:user)
      manually_sign_up(user.email, user.password)

      # message document was saved and the document itself should be visible
      expect(page).to have_selector('.notice.message p', '1 clipping was in temporary storage. It has been saved to your clipboard.')
      expect(page).to have_clipping_with_title('Test Document')
    end
  end

  context "a user with an account" do
    scenario "clips a document while not signed in, signs in, it should be added to their list of documents", :js do
      user = FactoryGirl.create(:user)
      clipping = FactoryGirl.create(:clipping, user_id: user.id)
      user.clippings = [clipping]
      user.save

      visit '/articles/2014/01/01/4242-4242/test-document'

      clip_current_document
      # use expectation to ensure ajax completes before moving on
      expect(page).to have_user_util("#doc_count", 1)

      manually_sign_in(user.email, user.password)

      # message document was saved and the document itself should be visible
      expect(page).to have_selector('.notice.message p', '1 clipping was in temporary storage. It has been saved to your clipboard.')
      expect(page).to have_clipping_with_title('Test Document')

      # two documents should be clipped
      expect(page).to have_user_util("#doc_count", 2)
      expect( page.all('#clippings li').count ).to eq(2)
    end

    scenario "clips a document while signed in, count should increment, and should show in the clipboard", :js do
      user = FactoryGirl.create(:user)
      clipping = FactoryGirl.create(:clipping, user_id: user.id)
      user.clippings = [clipping]
      user.save

      manually_sign_in(user.email, user.password)

      visit '/articles/2014/01/01/4242-4242/test-document'
      expect(page).to have_user_util("#doc_count", 1)

      clip_current_document
      # use expectation to ensure ajax completes before moving on
      expect(page).to have_user_util("#doc_count", 2)

      click_nav_item("My FR", "My Clipboard")

      # the document should be visible
      expect(page).to have_clipping_with_title('Test Document')

      # two documents should be clipped
      expect(page).to have_user_util("#doc_count", 2)
      expect( page.all('#clippings li').count ).to eq(2)
    end
  end
end
