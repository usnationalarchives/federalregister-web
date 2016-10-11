class Users::PasswordsController < Devise::PasswordsController

  def create
    if resource_params["email"] =~ Devise.email_regexp
      SendgridClient.new.remove_from_bounce_list(resource_params["email"])
    end

    super
  end

  protected

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path
    end
end
