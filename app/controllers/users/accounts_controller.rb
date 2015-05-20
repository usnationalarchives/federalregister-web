class Users::AccountsController < ApplicationController
  def index
    @user = current_user
  end

  def update
    current_user.email = params[:user][:email]
    current_user.confirmed_at = nil
    current_user.confirmation_token = nil

    if current_user.save
      current_user.send_confirmation_instructions

      current_user.subscriptions.each do |s|
        s.confirmed_at = nil
        s.email = params[:user][:email]
        s.save
      end

      flash[:notice] = t(
        'user.accounts.email_change_success',
        :email => params[:user][:email]
      )
      redirect_to accounts_path
    else
      flash[:error] = t(
        'user.accounts.email_change_failure',
        :email => params[:user][:email]
      )
      redirect_to accounts_path
    end
  end
end
