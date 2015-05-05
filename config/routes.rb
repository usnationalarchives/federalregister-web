MyFr2::Application.routes.draw do
  mount Stylin::Engine => '/styleguides' if Rails.env.development?

  match 'status', to: 'special#status'

  match "/404", to: "errors#record_not_found"
  match "/405", to: "errors#not_authorized"
  match "/500", to: "errors#server_error"

  #
  # Documents
  #
  get 'documents/current',
    to: "document_issues#current",
    as: :current_document_issue

  get 'documents/:year/:month/:day',
      to: "document_issues#show",
      as: :document_issue,
      constraints: {
        year:  /\d{4}/,
        month: /\d{1,2}/,
        day:   /\d{1,2}/
      }

  get 'document_issues/search',
      to: "document_issues#search",
      as: :document_issues_search,
      constraints: {
        date:  /\d{1,2}\/\d{1,2}\/\d{4}/
      }

  get 'documents/:year/:month/:day/:document_number/:slug',
      to: "documents#show",
      as: :document,
      constraints: {
        year:  /\d{4}/,
        month: /\d{1,2}/,
        day:   /\d{1,2}/,
        slug:  /[^\/]+/
      }

  # don't break old urls
  get '/a/:document_number',
      to: "documents#tiny_url"

  get '/d/:document_number',
      to: "documents#tiny_url",
      as: :short_document

  #
  # Documents Search
  #

  get 'documents/search',
    to: 'search/documents#show',
    as: 'documents_search'

  with_options(:quiet => true) do |esi|
    esi.get 'documents/search/header',
      to: 'search/documents#header',
      as: 'documents_search_header'

    esi.get 'documents/search/facets/:facet',
      to: 'search/documents#facets',
      as: 'documents_search_facets'

    esi.get 'documents/search/results',
      to: 'search/documents#results',
      as: 'documents_search_results'

    esi.get 'documents/search/suggestions',
      to: 'search/documents#suggestions',
      as: 'documents_search_suggestions'

    esi.get 'documents/search/help',
      to: 'search/documents#help',
      as: 'documents_search_help'
  end

  #
  # Public Inspection Documents
  #

  # legacy route that redirects to current
  get 'public-inspection',
      to: 'public_inspection_document_issues#public_inspection',
      as: :public_inspection

  get 'public-inspection/current',
    to: "public_inspection_document_issues#current",
    as: :current_public_inspection_issue

  get 'public-inspection/:year/:month/:day',
      to: "public_inspection_document_issues#show",
      as: :public_inspection_issue,
      constraints: {
        year:  /\d{4}/,
        month: /\d{1,2}/,
        day:   /\d{1,2}/
      }


  #
  # Public Inspection Documents Search
  #

  get 'public-inspection/search',
    to: 'search/public_inspection_documents#show',
    as: 'public_inspection_search'

  get 'public-inspection/search/header',
    to: 'search/public_inspection_documents#header',
    as: 'public_inspection_search_header'

  get 'public-inspection/search/results',
    to: 'search/public_inspection_documents#results',
    as: 'public_inspection_search_results'

  get 'public-inspection/search/facets/:facet',
    to: 'search/public_inspection_documents#facets',
    as: 'public_inspection_search_facets'


  #
  # Events Search
  #

  get 'events/search',
    to: 'events/search#show',
    as: 'events_search'


  #
  # Regulatory Plans Search
  #

  get 'regulatory_plans/search',
    to: 'regulatory_plans/search#show',
    as: 'regulatory_plans_search'

  #
  # ESI Routes
  #
  with_options(:quiet => true) do |esi|

    #CALENDAR
    esi.get 'esi/document_issues/:year/:month',
      to: 'document_issues#by_month',
      as: :document_issues_by_month,
      constraints: {
        :year        => /\d{4}/,
        :month       => /\d{1,2}/
      }

    esi.get 'esi/public_inspection_issues/:year/:month',
      to: 'public_inspection_document_issues#by_month',
      as: :public_inspection_issues_by_month,
      constraints: {
        :year        => /\d{4}/,
        :month       => /\d{1,2}/
      }


    # ISSUES
    esi.get 'esi/issues/summary',
      to: 'issues#summary',
      as: :issue_summary


    # HEADER
    esi.get 'special/navigation',
      to: 'special#navigation',
      as: :navigation

    esi.get 'special/user_utils',
      to: 'special#user_utils',
      as: :user_utils

    esi.get 'special/header/:type',
      to: 'special#header',
      as: :header,
      constraints: {
        type: /(official|public-inspection|reader-aids)/
      }

    esi.get 'special/site_notifications/:identifier',
      to: 'special#site_notifications',
      as: :site_notification


    # HOME PAGE
    esi.get 'esi/home/reader_aids',
      to: 'reader_aids#homepage',
      as: :home_reader_aids

    esi.get 'esi/home/explore_agencies',
      to: 'agencies#explore_agencies',
      as: :home_explore_agencies

    esi.get 'esi/home/explore_topics',
      to: 'topics#explore_topics',
      as: :home_explore_topics

    esi.get 'esi/home/presidential_documents',
      to: 'presidential_documents#homepage',
      as: :home_presidential_documents

    esi.get 'esi/home/sections',
      to: 'sections#homepage',
      as: :home_sections


    # READER AIDS
    esi.get 'esi/reader_aids/blog_highlights',
      to: 'reader_aids#blog_highlights',
      as: :reader_aids_blog_highlights

    esi.get 'esi/reader_aids/using_fr',
      to: 'reader_aids#using_fr',
      as: :reader_aids_using_fr

    esi.get 'esi/reader_aids/understanding_fr',
      to: 'reader_aids#understanding_fr',
      as: :reader_aids_understanding_fr

    esi.get 'esi/reader_aids/recent_updates',
      to: 'reader_aids#recent_updates',
      as: :reader_aids_recent_updates

    esi.get 'esi/reader_aids/videos_and_tutorials',
      to: 'reader_aids#videos_and_tutorials',
      as: :reader_aids_videos_and_tutorials

    esi.get 'esi/reader_aids/developer_tools',
      to: 'reader_aids#developer_tools',
      as: :reader_aids_developer_tools


    # NAVIGATION
    esi.get 'esi/layouts/navigation/sections',
      to: 'sections#navigation',
      as: :navigation_sections

    esi.get 'esi/layouts/navigation/agencies',
      to: 'agencies#navigation',
      as: :navigation_agencies

    esi.get 'esi/layouts/navigation/topics',
      to: 'topics#navigation',
      as: :navigation_topics

    esi.get 'esi/layouts/navigation/reader-aids',
      to: 'reader_aids#navigation',
      as: :navigation_reader_aids

    esi.get 'esi/layouts/navigation/public-inspection',
      to: 'public_inspection_document_issues#navigation',
      as: :navigation_public_inspection

    esi.get 'esi/layouts/navigation/document_issue',
      to: 'document_issues#navigation',
      as: :navigation_document_issue

    esi.get 'esi/layouts/navigation/executive-orders',
      to: 'executive_orders#navigation',
      as: :navigation_executive_orders

    # FOOTER
    esi.get 'esi/layout/footer',
      to: 'special#footer',
      as: :footer
  end


  #
  # Reader Aids
  #
  get 'reader-aids',
      to: 'reader_aids#index',
      as: :reader_aids

  get 'reader-aids/search',
      to: 'reader_aids#search',
      as: :reader_aids_search

  get 'reader-aids/:section',
      to: 'reader_aids#view_all',
      as: :reader_aids_section

  get 'reader-aids/:section/:item',
      to: 'reader_aids#show',
      as: :reader_aid

  #
  # Home
  #
  root to: 'special#home'


  #
  # Topics
  #
  resources :topics, only: [:index, :show]

  get 'topics/:id/significant.:format',
    :controller => "topics",
    :action => "significant_entries",
    :conditions => { :method => :get },
    as: 'significant_entries_topic'


  #
  # Agencies
  #
  get 'agencies/suggestions',
    controller: "agencies",
    actions: "suggestions",
    as: 'agency_suggestions'

  resources :agencies, only: [:index, :show]

  get 'agencies/:id/significant.:format',
    :controller => "agencies",
    :action => "significant_entries",
    :conditions => { :method => :get },
    as: 'significant_entries_agency'


  #
  # Executive Orders
  #
  match '/executive-orders',
    to: 'executive_orders#index',
    as: 'executive_orders'

  match '/executive-orders/:president/:year',
    to: 'executive_orders#by_president_and_year',
    as: 'executive_orders_by_president_and_year'


  #
  # Sections
  #
  get '/:section',
    to: 'sections#show',
    as: :section,
    constraints: {
      section: Regexp.new(Section.slugs.join("|"))
    }

  get 'sections/:id/significant.:format',
    :controller => "agencies",
    :action => "significant_entries",
    :conditions => { :method => :get },
    as: 'significant_entries_section'


  #
  # Suggested searches
  #
  get '/:slug',
    to: 'suggested_searches#show',
    as: :suggested_search

  #
  # FR Index
  #
  get '/index/:year',
    :controller => "indexes",
    :action => "year",
    as: 'index_year'

  get '/index/:year/:agency_slug',
    :controller => "indexes",
    :action => "year_agency",
    as: 'year_agency'

  #
  # My FR
  #
  scope 'my' do
    devise_for :users, :controllers => { :passwords => "users/passwords",
                                         :confirmations => "users/confirmations",
                                         :sessions => "users/sessions",
                                         :registrations => "users/registrations" }
    devise_scope :user do
      get 'sign_in', :to => 'users/sessions#new', :as => :new_session
      get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_session
      get 'sign_up', :to => 'users/registrations#new', :as => :user_registration
      post 'sign_up', :to => 'users/registrations#create', :as => :user_registration
      get 'resend_confirmation', :to => 'users/confirmations#resend', :as => :resend_confirmation
    end

    root :to => "clippings#index",
         :as => :my_root

    resources :accounts,
      :only => [:index, :update],
      :controller => "users/accounts"

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

    get 'documents/:document_number/comments/new' => 'comments#new',
     :as => :new_comment
    post 'documents/:document_number/comments/reload' => 'comments#reload',
     :as => :reload_comment
    post 'documents/:document_number/comments' => 'comments#create',
     :as => :comment

    resources :comment_attachments,
      :only => [:create, :destroy]

    resource :comment_publication_notifications,
      :only => [:create, :destroy]

    resource :comment_followup_document_notifications,
      :only => [:create, :destroy]

    get 'sections/:id/significant.:format',
      :controller => "agencies",
      :action => "significant_entries",
      :conditions => { :method => :get },
      as: 'significant_entries_section'

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

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount SubscriptionMailer::Preview => 'subscription_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
  end
end
