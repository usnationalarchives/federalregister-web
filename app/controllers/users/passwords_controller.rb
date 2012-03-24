class Users::PasswordsController < Devise::PasswordsController

  protected

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path
    end
end
