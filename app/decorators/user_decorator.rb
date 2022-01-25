class UserDecorator < ApplicationDecorator
  decorates :user
  delegate_all

  delegate :clippings,
           :id,
           :email,
           :update, to: :user

  def display_name
    user.try(:email)
  end

  def confirmed?
    user.email_confirmed
  end
end
