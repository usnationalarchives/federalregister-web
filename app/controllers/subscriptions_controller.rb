class SubscriptionsController < ApplicationController
  with_options(only: [
    :new, :create,
    :confirmation_sent, :confirm, :confirmed,
    :activate, :suspend,
    :unsubscribe, :unsubscribed, :destroy
  ]) do |during_creation|
    during_creation.skip_before_action :authenticate_user!
  end

  before_action :refresh_current_user, only: :index

  def index
    @subscriptions = SubscriptionDecorator.decorate_collection(
      current_user.subscriptions.order("subscriptions.created_at DESC")
    )
    @document_subscription_count = current_user.subscriptions.document_subscriptions.count
    @pi_subscription_count = current_user.subscriptions.pi_subscriptions.count
  end

  def create
    @subscription = Subscription.new(subscription_params)

    @subscription.requesting_ip = request.remote_ip
    @subscription.environment = Rails.env

    if user_signed_in?
      @subscription.user_id = current_user.id
    end

    if @subscription.save
      if user_signed_in?
        if current_user.confirmed?
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
      Honeybadger.notify(
        error_class: 'Subscription::Invalid',
        error_message: 'Unable to create subscripton',
        context: {
          subscription: @subscription.attributes,
          errors: @subscription.errors.messages
        }
      )

      raise ActiveRecord::RecordInvalid
    end
  end

  def unsubscribe
    @subscription = Subscription.find_by_token!(params[:id])
  end

  def activate
    if request.xhr?
      subscription = Subscription.find_by_token!(params[:id])
      subscription.activate!

      render json: {unsubscribe_url: suspend_subscription_path(subscription.token)}
    end
  end

  def suspend
    subscription = Subscription.find_by_token!(params[:id])
    subscription.suspend!

    if request.xhr?
      render json: {resubscribe_url: activate_subscription_path(subscription.token)}
    else
      SubscriptionMailer.unsubscribe_notice(subscription).deliver
      redirect_to unsubscribed_subscriptions_url
    end
  end

  def destroy
    if request.xhr?
      @subscription = Subscription.find_by_token!(params[:id])
      @subscription.destroy
      render json: {}
    end
  end

  def unsubscribed
  end

  def subscription_params
    params.require(:subscription).permit(
      :search_type,
      search_conditions: {}
    )
  end
end
