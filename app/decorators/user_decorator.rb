class UserDecorator < ApplicationDecorator
  decorates :user
  delegate_all
  
  delegate :clippings,
           :id,
           :email,
           :new_clippings_count,
           :update_attribute, to: :user

  def display_name
    if user.try(:first_name) || user.try(:last_name)
      [user.try(:first_name), user.try(:last_name)].compact.join(' ')
    elsif user.try(:email)
      user.email
    end
  end
end
