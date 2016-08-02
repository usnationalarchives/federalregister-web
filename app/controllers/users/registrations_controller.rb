class Users::RegistrationsController < Devise::RegistrationsController
  include UserDataPersistor

  def new
    resource = build_resource()
    respond_with resource
  end

  def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)

        message, redirect_location = persist_user_data
        flash[:notice] = message[:notice] if message[:notice]
        flash[:warning] = message[:warning] if message[:warning]

        respond_with resource, :location => redirect_location || after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end
end

