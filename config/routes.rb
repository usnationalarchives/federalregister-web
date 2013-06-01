MyFr2::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :passwords => "users/passwords" } do
    get '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_session
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

  match "404" => "errors#record_not_found"
  match "405" => "errors#not_authorized"
  match "500" => "errors#server_error"
end
