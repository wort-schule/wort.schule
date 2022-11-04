Rails.application.routes.draw do
  get "page/impressum"
  devise_for :users, path: "devise/users", controllers: {registrations: "registrations", sessions: "users/sessions"}

  root to: "nouns#index"

  resource :search, only: :show

  # Object routes
  resources :nouns do
    collection do
      get "by_genus/:genus", to: "nouns#by_genus", as: :by_genus
    end
  end
  resources :verbs
  resources :adjectives
  resources :users
  resources :schools do
    resources :teaching_assignments, only: %i[new create destroy]
    resources :learning_groups, except: :index do
      scope module: :learning_groups do
        resource :invitation, only: %i[show create destroy]
      end

      resources :learning_group_memberships, only: %i[new create destroy] do
        scope module: :learning_group_memberships do
          post :requests, to: "requests#create", on: :collection
          post "requests/accept", to: "requests#accept"
          post "requests/reject", to: "requests#reject"
        end
      end
    end
  end
  resources :compounds, only: :index
  resources :sources
  resources :function_words
  resources :topics
  resources :hierarchies
  resources :prefixes
  resources :postfixes
  resources :phenomenons
  resources :strategies
  resources :compound_interfixes
  resources :compound_preconfixes
  resources :compound_postconfixes
  resources :compound_phonemreductions
  resources :compound_vocalalternations

  # User's own routes
  resource :profile, only: %i[show edit update]
  resource :avatar, only: :destroy

  scope module: :profiles do
    resource :password, only: :edit
    resource :email, only: :edit
  end
end
