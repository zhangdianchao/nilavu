require_dependency "homepage_constraint"
require_dependency "permalink_constraint"

Nilavu::Application.routes.draw do

  get '/404', to: 'errors#not_found'
  get "/404-body" => "errors#not_found_body"
  get '/500', to: 'errors#internal_error'


  GROUPNAME_ROUTE_FORMAT = /[\w.\-]+/ unless defined? GROUPNAME_ROUTE_FORMAT
  USEREMAIL_ROUTE_FORMAT = /[\w.\-]+/ unless defined? USEREMAIL_ROUTE_FORMAT

  # named route for users, session
  resources :static
  post "login" => "static#enter"
  get "login" => "static#show", id: "login"
  get "password-reset" => "static#show", id: "password_reset"
  get "signup" => "static#show", id: "signup"
  get "torpedo.json" => 'cockpits#index', defaults: {format: 'json'}

  #session related
  resources :sessions
  get "session/csrf" => "sessions#csrf"
  match "sessions/:id", to:  "sessions#destroy", via: [:delete], constraints: {
    id: USEREMAIL_ROUTE_FORMAT
  }

  post "forgot_password" => "sessions#forgot_password"
  get "/password_reset" => "users#password_reset"
  put "/password_reset" => "users#password_reset"
  get "users/account-created/" => "users#account_created"


  match "/auth/:provider/callback", to: "omniauth_callbacks#complete", via: [:get, :post]
  match "/auth/failure", to: "omniauth_callbacks#failure", via: [:get, :post]

  resources :users, except: [:show, :update, :destroy] do
    collection do
      get "check_email"
    end
  end


  match "users/:id", to:  "users#show", via: [:get],defaults: {format: 'json'}




  get "stylesheets/:name.css" => "stylesheets#show", constraints: { name: /[a-z0-9_]+/ }

  get "launchables.json" => 'launchables#assemble', defaults: {format: 'json'}
  get "launchables/pools/:group_name.json" => "launchables#prepare", as: "launchables_pools_group", constraints: {
    group_name: GROUPNAME_ROUTE_FORMAT
  }
  get "launchables/summary.json" => "launchables#summarize", as: "launchables_summarize"

  ##
  get  "launchers/:id.json" => "launchers#launch"
  post "launchers.json" => "launchers#perform_launch"

  get "/ssh_keys/edit/:name", to: "ssh_keys#edit"
  get "/ssh_keys/:name.json", to: "ssh_keys#show", defaults: {format: 'json'}

  # Topics resource
  get "t/:id" => "topics#show"
  get "t/:id/:name" => "topics#request", as: "topic_action_group"
    put "t/:id" => "topics#update"
  delete "t/:id" => "topics#destroy"

  get 'notifications' => 'notifications#index'
  put 'notifications/mark-read' => 'notifications#mark_read'


  ##
  get "billings.json" => "billings#index", defaults: {format: 'json'}
  get "robots.txt" => "robots_txt#index"
  get "manifest.json" => "manifest_json#index", :as => :manifest

  post "storages.json" =>"buckets#create",defaults: {format: 'json'}

  root to: 'cockpits#entrance', :as => "entrance"

  #Metrics
  match '/metrics/:type', to: "metrics#get", via: [:get]

  get "*url", to: 'permalinks#show', constraints: PermalinkConstraint.new
end
