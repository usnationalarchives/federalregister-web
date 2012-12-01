MyFr2::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :passwords => "users/passwords" } do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_session
  end

  match 'special/user_utils' => 'special#user_utils'
  match 'special/shared_assets' => 'special#shared_assets'
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

  match "/404" => "errors#record_not_found"
  match "/405" => "errors#not_authorized"
  match "/500" => "errors#server_error"

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
