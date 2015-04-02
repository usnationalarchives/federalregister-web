require 'spec_helper'

feature "Creating clippings", :no_ci do
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
      expect(page).to have_selector('.warning.message p', text: 'These clippings are not permanently saved. Please sign in or sign up to save them permanently.')
      expect(page).to have_clipping_with_title('Test Document')
    end

    context "fr2 article page clipping menu" do
      scenario "attempting to create a new folder creates a modal with content about signing in/up", :js do
        visit '/articles/2014/01/01/4242-4242/test-document'

        within '#clipping-actions' do
          unclipped_my_clippings_menu_item = '.menu ul li.not_in_folder[data-slug="my-clippings"]'

          find('#add-to-folder').trigger(:mouseover)
          page.find('.menu ul li#new-folder').trigger(:click)
        end

        expect(page).to have_modal('#account-needed-modal')
        expect(page).to have_selector('#account-needed-modal p', text: 'Please sign in or create an account to use this functionality')
      end
    end
  end

  context "a non-logged in user who signs up" do
    scenario "should show as clipped on the page, in the user_utils area, and be available in my clippings once signed up", :js do
      visit '/articles/2014/01/01/4242-4242/test-document'

      clip_current_document
      click_user_util_item('Sign up')

      # sign up user
      user = build(:user)
      manually_sign_up(user.email, user.password)

      # message document was saved and the document itself should be visible
      expect(page).to have_selector('.notice.message p', text: '1 clipping was in temporary storage. It has been saved to your clipboard.')
      expect(page).to have_clipping_with_title('Test Document')
    end
  end

  context "a user with an account" do
    scenario "clips a document while not signed in, signs in, it should be added to their list of documents", :js do
      user = create(:user)
      clipping = create(:fr_clipping_2, user_id: user.id)
      user.clippings = [clipping]
      user.save

      visit '/articles/2014/01/01/4242-4242/test-document'

      clip_current_document
      # use expectation to ensure ajax completes before moving on
      expect(page).to have_user_util("#doc_count", 1)

      manually_sign_in(user.email, user.password)

      # message document was saved and the document itself should be visible
      expect(page).to have_selector('.notice.message p', text: '1 clipping was in temporary storage. It has been saved to your clipboard.')
      expect(page).to have_clipping_with_title('Test Document')

      # two documents should be clipped
      expect(page).to have_user_util("#doc_count", 2)
      expect( page.all('#clippings li').count ).to eq(2)
    end

    scenario "clips a document while signed in, count should increment, and should show in the clipboard", :js, :focus do
      user = create(:user)
      clipping = create(:fr_clipping_2, user_id: user.id)

      manually_sign_in(user.email, user.password)

      #binding.pry
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

    context "fr2 article page clipping menu" do
      let(:user) { create(:user) }

      scenario "interacting with my-clipping menu (clip, delete clipping)", :js do
        manually_sign_in(user.email, user.password)
        visit '/articles/2014/01/01/4242-4242/test-document'

        within '#clipping-actions' do
          unclipped_my_clippings_menu_item = '.menu ul li.not_in_folder[data-slug="my-clippings"]'
          clipped_my_clippings_menu_item = unclipped_my_clippings_menu_item.gsub('.not_in_folder', '.in_folder')

          find('#add-to-folder').trigger(:mouseover)

          expect(page).to have_selector(unclipped_my_clippings_menu_item + ' a span.name', text: 'My Clipboard')
          expect(page).to have_selector(unclipped_my_clippings_menu_item + ' a span.icon-fr2-badge_check_mark')

          find(unclipped_my_clippings_menu_item + ' a').trigger(:click)

          expect(page).to have_selector(clipped_my_clippings_menu_item + ' a span.name', text: 'My Clipboard')
          expect(page).to have_selector(clipped_my_clippings_menu_item + ' a span.icon-fr2-badge_check_mark')
        end

        expect(page).to have_user_util('#doc_count', 1)

        within '#clipping-actions' do
          unclipped_my_clippings_menu_item = '.menu ul li.not_in_folder[data-slug="my-clippings"]'
          clipped_my_clippings_menu_item = unclipped_my_clippings_menu_item.gsub('.not_in_folder', '.in_folder')

          # move mouse
          find('#add-to-folder').trigger(:mouseout)
          find('#add-to-folder').trigger(:mouseover)
          # this has to be done manually as the capybara drivers fail silently here when doing find().trigger()
          page.evaluate_script('$(".menu ul li.in_folder[data-slug=\"my-clippings\"]").trigger("mouseenter")')

          expect(page).not_to have_selector(clipped_my_clippings_menu_item + ' a span.icon-fr2-badge_check_mark')
          expect(page).to have_selector(clipped_my_clippings_menu_item + ' a span.delete.icon-fr2-badge_x')

          page.find(clipped_my_clippings_menu_item + ' a span.delete.icon-fr2-badge_x').trigger(:click)
          expect(page).not_to have_selector(clipped_my_clippings_menu_item + ' a span.delete.icon-fr2-badge_x')
          expect(page).to have_selector(unclipped_my_clippings_menu_item + ' a span.icon-fr2-badge_check_mark')

          #expect(page).to have_selector(clipped_my_clippings_menu_item + 'a span.goto.icon-fr2-badge_forward_arrow')
        end

        expect(page).to have_user_util('#doc_count', 0)
      end

      scenario "interacting with my-clipping menu (clip into new folder, go to folder)", :js do
        manually_sign_in(user.email, user.password)
        visit '/articles/2014/01/01/4242-4242/test-document'

        expect(page).to have_user_util('#user_folder_count', 0)
        expect(page).to have_user_util('#user_documents_in_folders_count', 0)

        within '#clipping-actions' do
          unclipped_my_clippings_menu_item = '.menu ul li.not_in_folder[data-slug="my-clippings"]'

          find('#add-to-folder').trigger(:mouseover)
          page.find('.menu ul li#new-folder').trigger(:click)
        end

        expect(page).to have_modal('#new-folder-modal')

        within '#new-folder-modal' do
          expect(page).to have_selector('p', text: 'Creating folders will help you organize your clipped articles. When this folder is created the current article will be added to that folder.')
          expect(page).to have_selector('input#folder_name')

          fill_in "folder_name", with: "Test folder"
          click_button 'Create Folder'

          #expect(page).to have_selector('.folder_create p', text: 'Creating folder and saving clipping...')
          expect(page).to have_selector('.folder_success p', text: 'Successfully created folder "Test folder"')
        end

        within '#clipping-actions' do
          find('#add-to-folder').trigger(:mouseover)
          expect(page).to have_selector('.menu ul li.in_folder[data-slug="test-folder"]', text: 'Test folder')
        end

        expect(page).to have_user_util('#doc_count', 0)
        expect(page).to have_user_util('#user_folder_count', 1)
        expect(page).to have_user_util('#user_documents_in_folders_count', 1)

        within '#clipping-actions' do
          test_folder_li = '.menu ul li.in_folder[data-slug="test-folder"]'
          # this has to be done manually as the capybara drivers fail silently here when doing find().trigger()
          page.evaluate_script("$('#{test_folder_li}').trigger('mouseenter')")
          find(test_folder_li + ' span.goto').trigger(:click)
        end

        expect(current_path).to eq('/my/folders/test-folder')
      end
    end
  end
end
