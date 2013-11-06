class ApplicationController < ActionController::Base
  include Userstamp

  protect_from_forgery

  before_filter :authenticate_user!
  before_filter :set_stampers
  before_filter :decorate_current_user

  if Rails.env.development?
    around_filter :use_vcr
  end

  def set_stampers
    User.stamper = self.current_user
  end

  def decorate_current_user
    @current_user = UserDecorator.decorate(current_user) if current_user
  end

  def cache_for(time)
    unless Rails.env.development?
      expires_in time, :public => true
    end
  end

  private

  rescue_from Exception, :with => :server_error
  def server_error(exception)
    Rails.logger.error(exception)
    notify_honeybadger(exception)

    raise exception
  end

  def after_sign_out_path_for(resource)
    new_session_path
  end

  def use_vcr
    VCR.eject_cassette
    VCR.use_cassette("development") { yield }
  end
end
