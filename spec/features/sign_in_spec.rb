require 'spec_helper'

feature "Signing in", :no_ci do
  let(:user) { FactoryGirl.create(:user) }

  scenario "providing incorrect password" do
    visit '/my/sign_in'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'wrongPassword'
    click_button 'Sign in'

    expect(page.find('.signup_bar')).to have_selector('.error', 'Invalid email or password. Perhaps you meant to sign up or need to reset your password above?')
  end

  scenario "providing incorrect email" do
    visit '/my/sign_in'

    fill_in 'Email', with: 'my.wrong.email@example.com'
    fill_in 'Password', with: user.email
    click_button 'Sign in'

    expect(page.find('.signup_bar')).to have_selector('.error', 'Invalid email or password. Perhaps you meant to sign up or need to reset your password above?')
  end

  context "a user with no saved clippings" do
    scenario "can successfully log in", :js do
      manually_sign_in(user.email, user.password)

      expect(page).to have_user_util('li', user.email)
    end

    context "but with documents in their cookies" do
      scenario "can successfully log in", :js do
        clip_document
        manually_sign_in(user.email, user.password)

        expect(page).to have_user_util('li', user.email)
      end
    end
  end

  context "a user with already saved clippings" do
    scenario "can successfully log in", :js do
      user.clippings = [FactoryGirl.create(:clipping, user_id: user.id)]
      manually_sign_in(user.email, user.password)

      expect(page).to have_user_util('li', user.email)
    end
  end
end
