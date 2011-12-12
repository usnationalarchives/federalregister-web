class UserDecorator < ApplicationDecorator
  decorates :user

  def display_name
    if user.first_name || user.last_name
      [user.first_name, user.last_name].compact.join(' ')
    elsif user.email
      user.email
    end
  end
end
