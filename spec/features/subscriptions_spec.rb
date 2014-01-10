require 'spec_helper'

feature "Subscriptions" do
  context "not logged in" do
    scenario "visiting 'My Subscriptions' redirects the user to the sign in page", :js do
      visit "/my/subscriptions"

      expect(current_path).to eq('/my/sign_in')
      #expect(page).to have_flash_error( I18n.translate('devise.failure.unauthenticated') )
    end

    context "with an confirmed account" do
      scenario "creating a new subscription asks the user to login and user can view subscription", :js do
        user = create(:user, confirmed_at: Time.now - 1.day)
        visit "/environment"

        subscription_link = page.find('.title a.subscription')
        subscription_link.click

        expect(page).to have_modal

        within('#subscription_0') do
          email_input = page.find('#subscription_email')
          expect( email_input.value ).to eq("")
          expect( email_input.disabled? ).to be(false)

          fill_in 'subscription_email', with: user.email
          find('input[type=submit]').click
        end

        expect(current_path).to eq('/my/sign_in')
        expect(page).to have_flash_notice('Please sign into to add this subscription to your My FR account.')

        within('form#new_user') do
          expect( find('#user_email').value ).to eq(user.email)

          fill_in 'user_password', with: user.password
          click_button 'Sign in'
        end

        expect(current_path).to eq('/my/subscriptions')

        subscription = SubscriptionOnPage.new('Articles whose Associated Unified Agenda Deemed Significant Under EO 12866 and in Environment')
        expect(page).to have_selector('#subscriptions li', count: 1)
        expect(page).to have_flash_notice("Successfully added '#{subscription.subscription_title}' to your account")

        expect(subscription.visible?).to be(true)
        expect(subscription.active?).to be(true)
      end
    end

    context "with an unconfirmed account" do
      scenario "creating a new subscription asks the user to login, but the user can not see their subscriptions", :js do
        user = create(:user)
        visit "/environment"

        subscription_link = page.find('.title a.subscription')
        subscription_link.click

        expect(page).to have_modal

        within('#subscription_0') do
          email_input = page.find('#subscription_email')
          expect( email_input.value ).to eq("")
          expect( email_input.disabled? ).to be(false)

          fill_in 'subscription_email', with: user.email
          find('input[type=submit]').click
        end

        expect(current_path).to eq('/my/sign_in')
        expect(page).to have_flash_notice('Please sign into to add this subscription to your My FR account.')

        within('form#new_user') do
          expect( find('#user_email').value ).to eq(user.email)

          fill_in 'user_password', with: user.password
          click_button 'Sign in'
        end

        expect(current_path).to eq('/my/subscriptions')

        expect(page).to have_selector('#subscriptions li', count: 0)
        expect(page).to have_flash_warning("Your subscription has been added to your account but you must confirm your email address before we can begin sending you results.")
      end
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

      scenario "creating a new subscription", :js do
        manually_sign_in(user.email, user.password)
        visit "/environment"

        subscription_link = page.find('.title a.subscription')
        subscription_link.click

        expect(page).to have_modal

        email_input = page.find('#subscription_0 #subscription_email')
        expect( email_input.value ).to eq(user.email)
        expect( email_input.disabled? ).to be(true)

        page.find('#subscription_0 input[type=submit]').click

        expect(current_path).to eq('/my/subscriptions')
        subscription = SubscriptionOnPage.new('Articles whose Associated Unified Agenda Deemed Significant Under EO 12866 and in Environment')

        expect(page).to have_selector('#subscriptions li', count: 1)
        expect(page).to have_flash_notice("Successfully subscribed to '#{subscription.subscription_title}'")

        expect(subscription.visible?).to be(true)
        expect(subscription.active?).to be(true)
      end
    end
  end
end

