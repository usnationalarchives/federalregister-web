require 'spec_helper'

feature "MyFR Folders" do
  let(:user) { create(:user) }

  scenario "creating a folder via the move to folder menu", :js do
    folder = build(:folder, user: user)
    manually_sign_in(user.email, user.password)

    within '#clipping-actions' do
      menu_wrapper = '#add-to-folder'
      new_folder_li = menu_wrapper + ' .menu ul li#new-folder'

      find( menu_wrapper ).trigger(:mouseover)
      find( new_folder_li ).trigger(:click)
    end

    expect(page).to have_modal('#new-folder-modal')

    within '#new-folder-modal' do
      expect(page).to have_selector('p', text: 'Creating folders will help you organize your clipped articles.')
      expect(page).to have_selector('input#folder_name')

      fill_in "folder_name", with: folder.name
      click_button 'Create Folder'

      #expect(page).to have_selector('.folder_create p', text: 'Creating folder and saving clipping...')
      expect(page).to have_selector('.folder_success p', text: "Successfully created folder \"#{folder.name}\"")
    end

    within '#clipping-actions' do
      menu_wrapper = '#add-to-folder'
      folder_li = menu_wrapper + " .menu li[data-slug='#{folder.slug}']"

      find(menu_wrapper).trigger(:mouseover)
      expect(page).to have_selector(folder_li, text: folder.name)
      expect(page).to have_selector(folder_li + ' .document_count .document_count_inner', text: 0)
    end

    expect(page).to have_user_util('#doc_count', 0)
    expect(page).to have_user_util('#user_folder_count', 1)
    expect(page).to have_user_util('#user_documents_in_folders_count', 0)
  end

  scenario 'moving a clipping to a folder via the move to folder menu and then going to folder via view items in menu', :js do
    clipping = create(:fr_clipping_1, user: user)
    folder = build(:folder)
    manually_sign_in(user.email, user.password)

    within '#clippings' do
      first('li .add_to_folder_pane input').set(true)
    end

    within '#clipping-actions' do
      menu_wrapper = '#add-to-folder'
      new_folder_li = menu_wrapper + ' .menu ul li#new-folder'

      find( menu_wrapper ).trigger(:mouseover)
      find( new_folder_li ).trigger(:click)
    end

    within '#new-folder-modal' do
      expect(page).to have_selector('p.instructions span#fyi', text: 'When this folder is created the 1 selected clipping will be moved to it.')

      fill_in "folder_name", with: folder.name
      click_button 'Create Folder'
    end

    within '#clipping-actions' do
      menu_wrapper = '#add-to-folder'
      folder_li = menu_wrapper + " .menu li[data-slug='#{folder.slug}']"

      find(menu_wrapper).trigger(:mouseover)
      expect(page).to have_selector(folder_li, text: folder.name)
      expect(page).to have_selector(folder_li + ' .document_count .document_count_inner', text: 1)
    end

    expect(page).to have_user_util('#doc_count', 0)
    expect(page).to have_user_util('#user_folder_count', 1)
    expect(page).to have_user_util('#user_documents_in_folders_count', 1)

    within '#clipping-actions' do
      jump_to_folder_menu_wrapper = "#jump-to-folder"
      folder_li = jump_to_folder_menu_wrapper + " .menu li[data-slug='#{folder.slug}']"

      find(jump_to_folder_menu_wrapper).trigger(:mouseover)

      expect(page).to have_selector(folder_li)
      expect(page).to have_selector(folder_li + ' .name', text: folder.name)
      expect(page).to have_selector(folder_li + ' .document_count .document_count_inner', text: 1)

      find( folder_li + ' .name' ).trigger(:click)
    end

    expect(current_path).to eq("/my/folders/#{folder.slug}")
    expect(page).to have_clipping_with_title(clipping.article.title)
  end
end
