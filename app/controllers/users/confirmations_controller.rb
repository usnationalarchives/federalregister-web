class Users::ConfirmationsController < Devise::ConfirmationsController
  
  def resend
    current_user.send_confirmation_instructions
    redirect_to subscriptions_path, :notice => "Resent confirmation instructions to #{current_user.email}"
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    subscriptions_path
  end
end
