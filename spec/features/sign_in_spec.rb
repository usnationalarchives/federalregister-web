require 'spec_helper'

feature "Signing in" do
  scenario "user can successfully log in and see their name", :js do
    user = FactoryGirl.create(:user)
    manually_sign_in(user.email, user.password)

    expect(page).to have_user_util('li', user.first_name)
  end
end
