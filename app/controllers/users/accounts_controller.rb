class Users::AccountsController < ApplicationController

def index
  @user = User.find(current_user.id)
end

def update
  current_user.email = params[:email]
  current_user.confirmed_at = nil
  current_user.confirmation_token = nil
  if current_user.save
    current_user.send_confirmation_instructions
    current_user.subscriptions.each do|s|
      s.confirmed_at = nil
      s.email = params[:email]
      s.save
    end
    flash[:notice] = "A confirmation email has been sent to #{params[:email]}"
    redirect_to accounts_path
  else
    flash[:error] = "Something went wrong with your update request.  Please re-enter your email address and try again."
    render 'index'
  end
end

end
