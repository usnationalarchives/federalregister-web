require 'spec_helper'

feature "Signing in", :no_ci do
  let(:user) { FactoryGirl.create(:user) }

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
