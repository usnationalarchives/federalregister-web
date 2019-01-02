module UserDataPersistor
  def persist_user_data
    # ensure session is set up to generate XSRF tokens
    #   as they are lazily-generated by Rails and the token
    #   is sometimes generated in ESIs, where changes to the
    #   session cookie would be lost
    form_authenticity_token

    # default
    message, redirect_location = {}, nil

    message, redirect_location = associate_clippings_with_user_at_sign_in_up if cookies[:document_numbers]
    message, redirect_location = associate_subscription if session[:subscription_token]
    message, redirect_location = associate_comment_with_user_at_sign_in_up if session[:comment_tracking_number] && session[:comment_secret]
    message, redirect_location = persist_subscription_messages if session[:subscription_notice] || session[:subscription_warning]

    return message, redirect_location
  end

  private

  def associate_subscription
    subscription = Subscription.where(:token => session[:subscription_token]).first

    if subscription
      subscription.user_id = current_user.id
      subscription.save :validate => false
      subscription.reload
      subscription.remove_from_bounce_list
    end

    # clean up
    session[:subscription_token] = nil

    redirect_location = subscriptions_path

    message = current_user.confirmed? ? {:notice => "Successfully added '#{subscription.mailing_list.title}' to your account"} : {:warning => "Your subscription has been added to your account but you must confirm your email address before we can begin sending you results."}

    return message, redirect_location
  end

  # allowing user to sign in / sign up after comment had been submitted
  def associate_comment_with_user_at_sign_in_up
    if session[:comment_tracking_number].present?
      comment = Comment.where(
        :user_id => nil,
        :comment_tracking_number => session[:comment_tracking_number]
      ).first
    else
      comment = Comment.where(
        :user_id => nil,
        :submission_key => session[:submission_key]
      ).first
    end

    if comment
      comment.user_id = current_user.id
      comment.secret = session[:comment_secret]
      comment.comment_publication_notification = session[:comment_publication_notification]

      comment.build_subscription(current_user, request)

      comment.save :validate => false

      if comment.user_id
        CommentMailer.comment_copy(
          User.new("id" => current_user.id, "email" => current_user.email),
          comment
        ).deliver_now
      end
    end

    redirect_location = comments_path

    if comment.nil?
      if session[:comment_tracking_number].present?
        comment = Comment.where(
          :comment_tracking_number => session[:comment_tracking_number]
        ).first
      else
        comment = Comment.where(
          :submission_key => session[:submission_key]
        ).first
      end

      if comment.blank? || (comment.user_id.blank? || comment.subscription.blank?)
        Honeybadger.notify(
          error_class:   "UnexpectedSessionCommentData",
          error_message: "Unknown data stored in session",
          context: {
            comment_tracking_number:          session[:comment_tracking_number],
            comment_secret:                   session[:comment_secret],
            comment_publication_notification: session[:comment_publication_notification],
            submission_key:                   session[:submission_key],
            followup_document_notification:   session[:followup_document_notification],
          }
        )
      end
      message = {}
    elsif session[:followup_document_notification] == '1' && !current_user.confirmed?
      message = {:warning => "Successfully added your comment on '#{comment.document.title}' to your account, but you will not receive notification about followup documents until you have confirmed your email address. #{view_context.link_to 'Resend confirmation email', resend_confirmation_path}."}
    else
      message = {:notice => "Successfully added your comment on '#{comment.document.title}' to your account."}
    end

    # clean up
    unless comment.nil?
      session[:comment_tracking_number]          = nil
      session[:comment_secret]                   = nil
      session[:comment_publication_notification] = nil
      session[:submission_key]                   = nil
      session[:followup_document_notification]   = nil
    end

    return message, redirect_location
  end

  # saving clippings from users session from before signed in or signed up
  def associate_clippings_with_user_at_sign_in_up
    create_from_cookie(cookies[:document_numbers], current_user)

    # clean up
    cookies[:document_numbers] = nil

    redirect_location = clippings_path
    message = {}

    return message, redirect_location
  end

  def persist_subscription_messages
    if session[:subscription_notice]
      message = {notice: session[:subscription_notice]}
      session[:subscription_notice] = nil
    else session[:subscription_warning]
      message = {warning: session[:subscription_warning]}
      session[:subscription_warning] = nil
    end

    return message, nil
  end

  def create_from_cookie(document_numbers, user)
    return unless document_numbers.present?

    document_numbers = JSON.parse(document_numbers)
    document_numbers.each do |doc_hash|
      doc_hash.each_pair do |document_number, folders|
        Clipping.persist_document(user, document_number, folders[0])
      end
    end

    session[:new_clippings_count] = document_numbers.count
  end
end
