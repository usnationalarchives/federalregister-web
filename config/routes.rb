Rails.application.routes.draw do
  get 'error_page', to: 'special#error_page' unless Rails.env.production?

  if Rails.env.development?
    mount FRMailer::Preview => 'fr_mail_view'
    mount SubscriptionMailer::Preview => 'subscription_mail_view'
    mount CommentMailer::Preview => 'comment_mail_view'
    mount DocumentMailer::Preview => 'document_mail_view'
  end

  get 'alive' => 'special#alive'
  get 'status', to: 'special#status'

  get '/robots.txt', to: 'special#robots'

  match '/404', to: 'application#not_found', via: :all, as: :not_found
  match '/405', to: 'application#not_authorized', via: :all, as: :not_authorized
  match '/500', to: 'application#server_error', via: :all, as: :server_error

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

  get 'documents/:document_number/emails/new',
    to: 'documents/emails#new',
    as: :new_document_email

  post 'documents/:document_number/emails',
    to: 'documents/emails#create',
    as: :document_email

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
  get '/a/:document_number(/:anchor)',
    to: "documents#tiny_url"

  get '/d/:document_number(/:anchor)',
    to: "documents#tiny_url",
    as: :short_document


  #
  # Documents Search
  #

  get 'documents/search',
    to: 'search/documents#show',
    as: 'documents_search'

  with_options(:quiet => true) do |js|
    js.get 'documents/search/count',
      to: 'search/documents#search_count',
      as: 'documents_search_search_count'
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

  get 'public_inspection_issues/search',
    to: "public_inspection_document_issues#search",
    as: :public_inspection_issues_search,
    constraints: {
      date:  /\d{1,2}\/\d{1,2}\/\d{4}/
    }


  #
  # Public Inspection Documents Search
  #

  get 'public-inspection/search',
    to: 'search/public_inspection_documents#show',
    as: 'public_inspection_search'

  with_options(:quiet => true) do |js|
    js.get 'public-inspection/search/count',
      to: 'search/public_inspection_documents#search_count',
      as: 'public_inspection_search_count'
  end

  get 'public_inspection_documents/:year/:month/:day/:document_number/:slug',
    to: redirect('/public-inspection/%{document_number}/%{slug}')
  get 'public-inspection/:document_number/:slug',
    to: "public_inspection_documents#show",
    as: :public_inspection_document,
    constraints: {
      slug:  /[^\/]+/
    }

  #
  # Citations
  #

  get 'select-citation/:year/:month/:day/:citation',
    to: 'citations#cfr',
    as: 'select_cfr_citation',
    constraints: {
      citation: /\d+-CFR-\d+(?:\.\d+)?/,
      year: /\d{4}/,
      month: /\d{1,2}/,
      day: /\d{1,2}/
    }

  get 'citation/:volume-FR-:page',
    as: 'citation',
    to: 'citations#fr',
    contraints: {volume: /\d+/, page: /\d+/}

  get 'executive-order/:eo_number',
    as:'executive_order',
    to: 'citations#eo',
    contraints: {eo_number: /\d+/}


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

    # HEADER
    esi.get '/esi/special/csrf_protection',
      to: 'special#csrf_protection',
      as: :csrf_protection

    esi.get 'special/site_notifications/:identifier',
      to: 'special#site_notifications',
      as: :site_notification

    # READER AIDS
    esi.get 'esi/reader_aids/:section',
      to: 'reader_aids#index_section',
      as: :reader_aids_index_section,
      constraints: {
        section: /(#{ReaderAid::SECTIONS.map{|k,v| k}.join('|')})/
      }


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

  get 'reader-aids/office-of-the-federal-register-blog',
    to: redirect("reader-aids/office-of-the-federal-register-announcements")

  get 'reader-aids/office-of-the-federal-register-blog/(*all)',
    to: redirect("reader-aids/office-of-the-federal-register-announcements/%{all}")

  get 'reader-aids/:section',
    to: 'reader_aids#section',
    as: :reader_aids_section

  get 'reader-aids/:section/*date/:page',
    to: 'reader_aids#show',
    as: :reader_aid_blog_post,
    contraints: {
      section: ['office-of-the-federal-register-announcements', 'recent-updates']
    }

  get 'reader-aids/:section/:page(/*subpage)',
    to: 'reader_aids#show',
    as: :reader_aid

  get '/policy/continuity-information', to: redirect('https://www.archives.gov/federal-register/write/newsletter/2024-may')


  #
  # Home
  #
  root to: 'special#home'


  #
  # Topics
  #

  get 'topics/suggestions',
    controller: "topics",
    actions: "suggestions",
    as: 'topics_suggestions'

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

  get '/executive-orders',
    to: redirect('/presidential-documents/executive-orders')

  get '/executive-orders/:president/:year',
    to: redirect('/presidential-documents/executive-orders/%{president}/%{year}')


  #
  # Presidential Documents
  #

  get '/presidential-documents',
    to: 'presidential_documents#index',
    as: :all_presidential_documents

  get '/presidential-documents/:type',
    to: 'presidential_documents#show',
    as: :presidential_documents,
    constraints: {
      type: Regexp.new("other-presidential-documents|executive-orders|proclamations")
    }

  get '/presidential-documents/:type/:president/:year',
    to: 'presidential_documents#by_president_and_year',
    as: 'presidential_documents_by_president_and_year',
    constraints: {
      type: Regexp.new("other-presidential-documents|executive-orders|proclamations")
    }


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
    :controller => "sections",
    :action => "significant_entries",
    :conditions => { :method => :get },
    as: 'significant_entries_section'


  #
  # Single Sign On
  #

  get '/auth/sign_in', to: 'sessions#new'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/sign_out', to: 'sessions#destroy', as: :sign_out


  #
  # API
  #
  scope "api" do
    namespace :v1 do
      resources :clippings, only: [:index]
    end
  end

  #
  # API Documentation
  #
  get '/developers/documentation/api/v1', to: 'api_documentation#show', as: :api_documentation


  #
  # Suggested searches
  #

  get '/:slug',
    to: 'suggested_searches#show',
    as: :suggested_search,
    constraints: SuggestedSearchContraint.new


  #
  # FR Index
  #

  get '/index/:year',
    controller: "indexes",
    action: "year",
    as: 'index_year',
    constraints: {
      year: /(19|20)\d{2}/
    }

  get '/index/:year/:agency_slug',
    controller: "indexes",
    action: "year_agency",
    as: 'year_agency_index',
    constraints: {
      year: /(19|20)\d{2}/
    }

  resources :zendesk_tickets, only: [:create]

  #
  # My FR
  #

  scope 'my' do
    root :to => "clippings#index",
         :as => :my_root

    resources :clippings do
      collection do
        post 'bulk_create'
      end
    end

    get 'folders/my-clippings', to: redirect('/my/clippings')
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
    post 'documents/:document_number/comments' => 'comments#create',
     :as => :comment

    resource :comment_publication_notifications,
      :only => [:create, :destroy]

    resource :comment_followup_document_notifications,
      :only => [:create, :destroy]

    resources :subscriptions, except: [:show, :new] do
      member do
        get :activate
        get :suspend
        get :unsubscribe
      end

      collection do
        get :unsubscribed
      end
    end
  end
end
