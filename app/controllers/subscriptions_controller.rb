class SubscriptionsController < ApplicationController
  with_options(only: [:new, :create, :confirmation_sent, :confirm, :confirmed, :unsubscribe, :unsubscribed, :destroy]) do |during_creation|
    during_creation.skip_before_filter :authenticate_user!
  end

  def index
    @subscriptions = SubscriptionDecorator.decorate_collection(
      current_user.subscriptions.order("subscriptions.created_at DESC")
    )
    @article_subscription_count = current_user.subscriptions.article_subscriptions.count
    @pi_subscription_count = current_user.subscriptions.pi_subscriptions.count
  end

  def new
    @subscription = Subscription.new(params[:subscription])
    @subscription.search_type ||= 'Document'

    @mailing_list_title = @subscription.mailing_list.title
  rescue FederalRegister::Client::BadRequest
    render :action => "invalid_subscription"
  end

  def create
    @subscription = Subscription.new(params[:subscription])

    @subscription.requesting_ip = request.remote_ip
    @subscription.environment = Rails.env

    if user_signed_in?
      @subscription.user = current_user
      @subscription.email = current_user.email
    end

    if @subscription.save
      if user_signed_in?
        if current_user.confirmed?
          @subscription.confirm!
          flash[:notice] = "Successfully subscribed to '#{@subscription.mailing_list.title}'"
        else
          flash[:warning] = "Your subscription has been added to your account but you must confirm your email address before we can begin sending you results."
        end

        redirect_to subscriptions_url
      elsif @subscription.user_with_this_email_exists?
        session[:subscription_token] = @subscription.token
        flash[:notice] = "Please sign into to add this subscription to your My FR account."

        redirect_to new_session_path(user: {email: @subscription.email})
      else
        SubscriptionMailer.subscription_confirmation(@subscription).deliver
        redirect_to confirmation_sent_subscriptions_url(email: @subscription.email)
      end
    else
      render action: :new
    end
  end

  def confirmation_sent
  end

  def confirm
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.confirm!

    respond_to do |format|
      format.html {
        redirect_to confirmed_subscriptions_path(type: @subscription.mailing_list.type)
      }
      format.json {
        render json: {unsubscribe_url: subscription_path(@subscription)}
      }
    end
  end

  def confirmed
  end

  def unsubscribe
    @subscription = Subscription.find_by_token!(params[:id])
  end

  def destroy
    @subscription = Subscription.find_by_token!(params[:id])
    @subscription.unsubscribe!

    unless request.xhr?
      SubscriptionMailer.unsubscribe_notice(@subscription).deliver
    end

    respond_to do |format|
      format.html {
        redirect_to unsubscribed_subscriptions_url
      }
      format.json {
        render json: {resubscribe_url: confirm_subscription_url(@subscription)}
      }
    end
  end

  def unsubscribed
  end
end
