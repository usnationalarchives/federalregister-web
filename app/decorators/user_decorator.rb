class UserDecorator < ApplicationDecorator
  decorates :user
  delegate_all
  
  delegate :clippings,
           :id,
           :email,
           :update_attribute, to: :user

  def display_name
    user.try(:email)
  end

  def confirmed?
    user.confirmed_at.present?
  end
end
