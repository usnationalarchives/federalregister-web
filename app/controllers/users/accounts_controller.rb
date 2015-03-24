class Users::AccountsController < ApplicationController

def index
  @user = User.find(current_user.id)
end

def update
  user = User.find(current_user.id)
  if user.update_attributes(strong_params.merge(confirmed_at: nil))
    user.send_confirmation_instructions
    user.subscriptions.each {|s|s.confirmed_at = nil; s.save}
    flash[:notice] = "A confirmation email has been sent to #{params[:email]}"
    redirect_to accounts_path
  else
    flash[:error] = "Something went wrong with your update request.  Please re-enter your email address and try again."
    render 'index'
  end
end

private

def strong_params
  params.permit(:email)
end

end