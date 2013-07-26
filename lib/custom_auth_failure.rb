class CustomAuthFailure < Devise::FailureApp
  def redirect_url
    if warden_options[:scope] == :user
      new_session_url
    else
      new_session_url
    end
  end
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
