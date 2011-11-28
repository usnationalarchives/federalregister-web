class AuthenticationsController < ApplicationController
  def index  
    @authentications = current_user.authentications if current_user  
  end 
end
