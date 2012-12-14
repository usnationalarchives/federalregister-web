MyFr2::Application.routes.draw do

scope "/my" do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", 
                                       :passwords => "users/passwords", 
                                       :confirmations => "users/confirmations",
                                       :sessions => "users/sessions",
                                       :registrations => "users/registrations" } do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_session
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

  match "404" => "errors#record_not_found"
  match "405" => "errors#not_authorized"
  match "500" => "errors#server_error"

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
  end
end
end
