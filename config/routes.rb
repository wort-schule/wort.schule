Rails.application.routes.draw do
  # These shortlinks have to be the first routes. They are used for URLs
  # without a controller, such as http://host/myword
  resources :nouns, except: %i[index new create], path: "", constraints: SlugConstraint.new(Noun)
  resources :verbs, except: %i[index new create], path: "", constraints: SlugConstraint.new(Verb)
  resources :adjectives, except: %i[index new create], path: "", constraints: SlugConstraint.new(Adjective)
  resources :function_words, except: %i[index new create], path: "", constraints: SlugConstraint.new(FunctionWord)

  concern :themeable do
    get :theme, action: :theme
  end

  root to: "nouns#index"

  devise_for :users, path: "devise/users", controllers: {registrations: "registrations", sessions: "users/sessions"}

  resource :search, only: :show

  # Object routes
  resources :nouns, only: %i[index new create] do
    member { concerns :themeable }

    collection do
      get "by_genus/:genus", to: "nouns#by_genus", as: :by_genus
    end
  end
  resources :verbs, only: %i[index new create] do
    member { concerns :themeable }
  end
  resources :adjectives, only: %i[index new create] do
    member { concerns :themeable }
  end
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
  resources :function_words, only: %i[index new create]
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
  resources :themes
  resources :lists
  post :list_add_word, to: "lists#add_word"

  # User's own routes
  resource :profile, only: %i[show edit update] do
    resources :themes, only: %i[index update], module: :profiles
  end
  resource :avatar, only: :destroy

  scope module: :profiles do
    resource :password, only: :edit
    resource :email, only: :edit
  end

  get "page/impressum"
end
