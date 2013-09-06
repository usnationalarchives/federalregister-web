class Users::ConfirmationsController < Devise::ConfirmationsController
  
  def resend
    current_user.send_confirmation_instructions
    redirect_to subscriptions_path, :notice => "Resent confirmation instructions to #{current_user.email}"
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      current_user.subscriptions.unconfirmed.each{|s| s.confirm!}
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    if params[:return_to].present?
      params[:return_to]
    else
      clippings_path
    end
  end
end
