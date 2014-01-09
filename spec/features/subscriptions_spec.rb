require 'spec_helper'

feature "Subscriptions" do
  context "not logged in" do
    scenario "redirects the user to the sign in page", :js do
      visit "/my/subscriptions"

      expect(current_path).to eq('/my/sign_in')
      #expect(page).to have_flash_error( I18n.translate('devise.failure.unauthenticated') )
    end
  end

  context "logged in" do
    let(:user) { FactoryGirl.create(:user) }

    scenario "but email address not confirmed", :js, :focus do
      manually_sign_in(user.email, user.password)
      visit "/my/subscriptions"

      expect(current_path).to eq("/my/subscriptions")
      expect(page).to have_fr_warning_message
      expect(page.find('.warning.message')).to have_selector('a', text: 'click here to resend')

      page.find('a', text: 'click here to resend').click

      open_last_email_for(user.email)
      expect(current_email).to be_delivered_to(user.email)
      expect(current_email).to have_subject("[FR] MyFR Email Confirmation")

      click_email_link_matching(/confirmation\?/)

      expect(page).to have_flash_notice('Your account was successfully confirmed. You are now signed in.')
      visit "/my/subscriptions"

      expect(page).to_not have_fr_warning_message
    end
  end
end

