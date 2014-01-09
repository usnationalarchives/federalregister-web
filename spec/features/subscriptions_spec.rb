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

    scenario "but email address not confirmed", :js do
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

    context "email address confirmed" do
      before(:each) do
        user.confirmed_at = Time.now - 1.day
        user.save
      end

      scenario "no subscriptions", :js do
        manually_sign_in(user.email, user.password)
        visit "/my/subscriptions"

        expect(page).to have_page_title('My Subscriptions')
        expect(page).to have_fr_notice_message(/You do not currently have any subscriptions/)
        expect(page).to have_subscriptions_metadata_item('li .entry_subscription_on_page_count', 0)
        expect(page).to have_subscriptions_metadata_item('li .pi_subscription_on_page_count', 0)
      end

      scenario "with 1 document subscription", :js do
        create(:document_subscription, user: user)

        login_as(user)
        visit "/my/subscriptions"

        expect(page).to have_subscriptions_metadata_item('li .entry_subscription_on_page_count', 1)
        expect(page).to have_subscriptions_metadata_item('li .pi_subscription_on_page_count', 0)

        expect(page).to have_selector('#subscription-type-filter')
        expect(page).to have_subscription_filter_enabled('Document')
        expect(page).to_not have_subscription_filter_enabled('Public Inspection')
      end

       scenario "with 1 public inspection document subscription", :js do
        create(:public_inspection_subscription, user: user)

        login_as(user)
        visit "/my/subscriptions"

        expect(page).to have_subscriptions_metadata_item('li .entry_subscription_on_page_count', 0)
        expect(page).to have_subscriptions_metadata_item('li .pi_subscription_on_page_count', 1)

        expect(page).to have_selector('#subscription-type-filter')
        expect(page).to_not have_subscription_filter_enabled('Document')
        expect(page).to have_subscription_filter_enabled('Public Inspection')
      end

      context "subscription filters" do
        scenario "filter the types of subscriptions currently displayed", :js do
          create(:document_subscription, user: user)
          create(:public_inspection_subscription, user: user)

          login_as(user)
          visit "/my/subscriptions"

          expect(page).to have_selector('#subscriptions li', count: 2)

          expect(page).to have_selector('#subscription-type-filter')
          expect(page).to have_subscription_filter_enabled('Document')
          expect(page).to have_subscription_filter_enabled('Public Inspection')

          toggle_subscription_filter('Document')
          expect(page).to_not have_subscription_filter_enabled('Document')
          expect(page).to have_selector('#subscriptions li', count: 1)
          expect(page).to have_selector('#subscriptions li[data-doc-type=article]', count: 0)

          toggle_subscription_filter('Document')
          expect(page).to have_subscription_filter_enabled('Document')
          expect(page).to have_selector('#subscriptions li', count: 2)
          expect(page).to have_selector('#subscriptions li[data-doc-type=article]', count: 1)

          toggle_subscription_filter('Public Inspection')
          expect(page).to_not have_subscription_filter_enabled('Public Inspection')
          expect(page).to have_selector('#subscriptions li', count: 1)
          expect(page).to have_selector('#subscriptions li[data-doc-type=public-inspection-document]', count: 0)

          toggle_subscription_filter('Public Inspection')
          expect(page).to have_subscription_filter_enabled('Public Inspection')
          expect(page).to have_selector('#subscriptions li', count: 2)
          expect(page).to have_selector('#subscriptions li[data-doc-type=public-inspection-document]', count: 1)
        end
      end

      context "suspending and activating a subscription" do
        scenario "suspending a subscription", :js do
          create(:document_subscription, user: user)
          manually_sign_in(user.email, user.password)
          visit "/my/subscriptions"

          unsubscribe_link = page.find('#subscriptions .subscription_data a.unsubscribe')

          unsubscribe_link.click
          expect(page).to have_selector('#subscriptions .subscription_data a.resubscribe')

          reload_page
          expect(page).to have_selector('#subscriptions .subscription_data a.resubscribe')
        end

        scenario "activating a subscription", :js do
          create(:document_subscription, user: user, confirmed_at: nil)
          manually_sign_in(user.email, user.password)
          visit "/my/subscriptions"

          unsubscribe_link = page.find('#subscriptions .subscription_data a.resubscribe')

          unsubscribe_link.click
          expect(page).to have_selector('#subscriptions .subscription_data a.unsubscribe')

          reload_page
          expect(page).to have_selector('#subscriptions .subscription_data a.unsubscribe')
        end
      end
    end
  end
end

