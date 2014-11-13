MyFr2::Application.routes.draw do
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

  with_options(:quiet => true) do |esi|
    esi.match 'special/user_utils' => 'special#user_utils'
    esi.match 'special/shared_assets' => 'special#shared_assets'
    esi.match 'special/my_fr_assets' => 'special#my_fr_assets'
    esi.match 'special/fr2_assets' => 'special#fr2_assets'
    esi.match 'special/navigation' => 'special#navigation'
    esi.match 'special/site_notifications/:identifier' => 'special#site_notifications', :as => :site_notification
  end

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
  get 'articles/:document_number/comments/new' => 'comments#new',
   :as => :new_comment
  post 'articles/:document_number/comments/reload' => 'comments#reload',
   :as => :reload_comment
  post 'articles/:document_number/comments' => 'comments#create',
   :as => :comment

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

  match "404" => "errors#record_not_found"
  match "405" => "errors#not_authorized"
  match "500" => "errors#server_error"

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount SubscriptionMailer::Preview => 'subscription_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
  end
end
