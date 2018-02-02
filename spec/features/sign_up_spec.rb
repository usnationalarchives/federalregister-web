require 'spec_helper'

feature "Signing up", :no_ci do
  let(:user) { build(:user) }

  scenario "signing up with prior subscriptions attributed to your email address", :js do
    create(:document_subscription, user: nil, email: user.email, confirmed_at: 1.month.ago)

    manually_sign_up(user.email, user.password)

    visit "/my/subscriptions"

    expect(page).to have_fr_warning_message

    open_last_email_for(user.email)
    expect(current_email).to be_delivered_to(user.email)
    expect(current_email).to have_subject("[FR] MyFR Email Confirmation")

    click_email_link_matching(/confirmation\?/)

    expect(page).to have_flash_notice('Your account was successfully confirmed. You are now signed in.')
    visit "/my/subscriptions"

    subscription = SubscriptionOnPage.new('All Documents')
    expect(page).to_not have_fr_warning_message
    expect(page).to have_selector('#subscriptions li', count: 1)
    expect(subscription.visible?).to be(true)
    expect(subscription.active?).to be(true)
  end
end
