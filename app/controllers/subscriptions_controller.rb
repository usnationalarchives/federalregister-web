class SubscriptionsController < ApplicationController
  with_options(only: [:new, :create, :confirmation_sent, :confirm, :confirmed, :unsubscribe, :unsubscribed, :destroy]) do |during_creation|
    during_creation.skip_before_filter :authenticate_user!
  end

  before_filter :refresh_current_user, only: :index

  def index
    @subscriptions = SubscriptionDecorator.decorate_collection(
      current_user.subscriptions.order("subscriptions.created_at DESC")
    )
    @document_subscription_count = current_user.subscriptions.document_subscriptions.count
    @pi_subscription_count = current_user.subscriptions.pi_subscriptions.count
  end

  def create
    @subscription = Subscription.new(params[:subscription])

    @subscription.requesting_ip = request.remote_ip
    @subscription.environment = Rails.env
    @subscription.email = nil

    if user_signed_in?
      @subscription.user_id = current_user.id
    end

    if @subscription.save
      if user_signed_in?
        if current_user.confirmed?
          @subscription.confirm!
          if verified_request?
            flash[:notice] = I18n.t('subscriptions.save.success', title: @subscription.mailing_list.title)
          else
            session[:subscription_notice] = I18n.t('subscriptions.save.success', title: @subscription.mailing_list.title)
          end
        else
          if verified_request?
            flash[:warning] = I18n.t('subscriptions.save.unconfirmed')
          else
            session[:subscription_warning] = I18n.t('subscriptions.save.unconfirmed')
          end
        end

        redirect_to subscriptions_url
      else
        session[:subscription_token] = @subscription.token

        redirect_to sign_in_url(
          nil,
          {notice: I18n.t('subscriptions.save.sign_in_required') }
        )
      end
    else
      raise NotImplementedError
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
