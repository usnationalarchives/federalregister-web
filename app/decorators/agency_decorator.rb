class AgencyDecorator < ApplicationDecorator
  delegate_all

  def name_and_short_name
    "#{name} (#{short_name})"
  end
end
