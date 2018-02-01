class UserDecorator < ApplicationDecorator
  decorates :user
  delegate_all
  
  delegate :clippings,
           :id,
           :email,
           :update_attribute, to: :user

  def display_name
    if user.try(:first_name) || user.try(:last_name)
      [user.try(:first_name), user.try(:last_name)].compact.join(' ')
    elsif user.try(:email)
      user.email
    end
  end

  def confirmed?
    user.confirmed_at.present?
  end
end
