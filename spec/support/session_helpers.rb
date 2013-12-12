module Features
  module SessionHelpers
    def manually_sign_in(email, password)
      visit '/my/sign_in'

      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end

    def reload_page
      visit current_path
    end
  end
end

