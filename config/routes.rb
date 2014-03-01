MyFr2::Application.routes.draw do
  mount Stylin::Engine => '/styleguides' if Rails.env.development?

  #
  # Document routes
  #

  get 'documents/:year/:month/:day',
      to: "documents#index",
      as: :documents,
      constraints: {
        :year        => /\d{4}/,
        :month       => /\d{1,2}/,
        :day         => /\d{1,2}/
      }

  get 'documents/:year/:month/:day/:document_number/:slug',
      to: "documents#show",
      as: :document,
      constraints: {
        year: /\d{4}/,
        month: /\d{1,2}/,
        day: /\d{1,2}/,
        slug: /[^\/]+/
      }

  # don't break old urls
  get '/a/:document_number',
      to: "documents#tiny_url"

  get '/d/:document_number',
      to: "documents#tiny_url",
      as: :short_document

  #
  # ESI Routes
  #
  get 'special/header/:type',
      to: 'special#header',
      constraints: {
        type: /(official|public-inspection|reader-aids)/
      }

  scope 'my' do
    devise_for :users, :controllers => { :passwords => "users/passwords",
                                         :confirmations => "users/confirmations",
                                         :sessions => "users/sessions",
                                         :registrations => "users/registrations" } do
      get 'sign_in', :to => 'users/sessions#new', :as => :new_session
      get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_session
      get 'sign_up', :to => 'users/registrations#new', :as => :user_registration
      post 'sign_up', :to => 'users/registrations#create', :as => :user_registration
      get 'resend_confirmation', :to => 'users/confirmations#resend', :as => :resend_confirmation
    end

    match 'special/user_utils' => 'special#user_utils'
    match 'special/shared_assets' => 'special#shared_assets'
    match 'special/my_fr_assets' => 'special#my_fr_assets'
    match 'special/fr2_assets' => 'special#fr2_assets'
    match 'special/navigation' => 'special#navigation'
    match 'status' => 'special#status'

    root :to => "clippings#index"

    resources :clippings do
      collection do
        post 'bulk_create'
      end
    end

    match 'folders/my-clippings' => 'clippings#index'
    resources :folders
    resources :folder_clippings do
      collection do
        post 'delete'
      end
    end

    resources :comments, :only => [:index] do
      collection do
        post :persist_for_login
      end
    end
    match 'articles/:document_number/comments/new' => 'comments#new',
     :as => :new_comment,
     :via => :get
    match 'articles/:document_number/comments/reload' => 'comments#reload',
     :as => :reload_comment,
     :via => :post
    match 'articles/:document_number/comments' => 'comments#create',
     :as => :comment,
     :via => :post

    resources :comment_attachments,
      :only => [:create, :destroy]

    resource :comment_publication_notifications,
      :only => [:create, :destroy]

    resource :comment_followup_document_notifications,
      :only => [:create, :destroy]

    resources :subscriptions do
      member do
        get :unsubscribe
        get :confirm
      end

      collection do
        get :confirmation_sent
        get :confirmed
        get :unsubscribed
      end
    end
  end

  match "/404", :to => "errors#record_not_found"
  match "/405", :to => "errors#not_authorized"
  match "/500", :to => "errors#server_error"

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount SubscriptionMailer::Preview => 'subscription_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
  end
end
