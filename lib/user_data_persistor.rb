module UserDataPersistor

  def persist_user_data
    # default
    message, redirect_location = {}, nil

    message, redirect_location = associate_clippings_with_user_at_sign_in_up if cookies[:document_numbers]
    message, redirect_location = associate_subscription if session[:subscription_token]
    message, redirect_location = associate_comment_with_user_at_sign_in_up if session[:comment_tracking_number] && session[:comment_secret]

    return message, redirect_location
  end

  private

  def associate_subscription
    subscription = Subscription.where(:token => session[:subscription_token]).first

    if subscription
      subscription.user = current_user
      subscription.save :validate => false

      subscription.confirm! if current_user.confirmed?
    end

    # clean up
    session[:subscription_token] = nil

    redirect_location = subscriptions_path

    message = current_user.confirmed? ? {:notice => "Successfully added '#{subscription.mailing_list.title}' to your account"} : {:warning => "Your subscription has been added to your account but you must confirm your email address before we can begin sending you results."}

    return message, redirect_location
  end

  # allowing user to sign in / sign up after comment had been submitted
  def associate_comment_with_user_at_sign_in_up
    comment = Comment.where(:user_id => nil, :comment_tracking_number => session[:comment_tracking_number]).first

    if comment
      comment.user = current_user
      comment.secret = session[:comment_secret]
      comment.comment_publication_notification = session[:comment_publication_notification]

      if session[:followup_document_notification]
        comment.build_subscription(current_user, request)
      end

      comment.save :validate => false

      CommentMailer.comment_copy(comment.user, comment).deliver
    end

    # clean up
    session[:comment_tracking_number] = nil
    session[:comment_secret] = nil
    session[:comment_publication_notification] = nil
    session[:followup_document_notification] = nil

    redirect_location = comments_path
    message = {:notice => "Successfully added your comment on '#{comment.article.title}' to your account."}

    return message, redirect_location
  end

  # saving clippings from users session from before signed in or signed up
  def associate_clippings_with_user_at_sign_in_up
    Clipping.create_from_cookie( cookies[:document_numbers], current_user )

    # clean up
    cookies[:document_numbers] = nil

    redirect_location = clippings_path
    message = {}

    return message, redirect_location
  end
end
