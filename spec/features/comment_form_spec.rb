require 'spec_helper'

feature "Regulations.gov comment integration" do
  scenario "User submits a comment for a document that has an open comment period", :js do
    visit '/articles/2013/11/19/2013-27495/lake-tahoe-basin-management-unit-california-heavenly-mountain-resort-epic-discovery-project'

    expect(page).to have_comment_bar('#start_comment')

    within('#flash_message.comment') do
      click_on('start_comment')
    end

    expect(page).to have_selector('div.loading')
    expect(page).to have_selector('span.loader', :text => 'Loading Comment Form')

    expect(page).to have_selector('div.comment_wrapper')
  end
end
