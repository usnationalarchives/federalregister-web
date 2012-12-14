class Users::SessionsController < Devise::SessionsController
  include UserDataPersistor

  def create
    resource = warden.authenticate!(auth_options)

    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)

    notice, redirect_location = persist_user_data
    flash[:notice] = notice if notice
        
    respond_with resource, :location => redirect_location || after_sign_in_path_for(resource)
  end

end
