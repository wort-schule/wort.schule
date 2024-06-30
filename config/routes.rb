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

  concern :list_addable do
    post :add_to_list, action: :add_to_list
  end

  root to: "homes#show"

  scope Rails.configuration.default_app_namespace do
    devise_for :users, path: "devise/users", controllers: {registrations: "registrations", sessions: "users/sessions"}

    get "impressum", to: "pages#imprint", as: :imprint
    get "sonstiges", to: "pages#navigation", as: :navigation
    get "wort-index/:letter", to: "seo#word_index", as: :word_index, defaults: {letter: "a"}

    resource :search, only: :show
    resources :searches do
      collection do
        concerns :list_addable
      end
    end

    # Object routes
    resources :nouns, only: %i[index new create] do
      member { concerns :themeable }

      collection do
        get "by_genus/:genus", to: "nouns#by_genus", as: :by_genus
        concerns :list_addable
      end
    end
    resources :verbs, only: %i[index new create] do
      member { concerns :themeable }
      collection do
        concerns :list_addable
      end
    end
    resources :adjectives, only: %i[index new create] do
      member { concerns :themeable }
      collection do
        concerns :list_addable
      end
    end
    resources :users
    resources :learning_groups do
      scope module: :learning_groups do
        resource :invitation, only: %i[show create destroy]
        resource :user_generation
      end

      resources :learning_group_memberships, only: %i[new create update destroy] do
        patch :reset_password, on: :member

        scope module: :learning_group_memberships do
          post :requests, to: "requests#create", on: :collection
          post "requests/accept", to: "requests#accept"
          post "requests/reject", to: "requests#reject"
        end
      end
      resources :learning_pleas, only: %i[new create destroy]
    end
    resources :compounds, only: :index
    resources :sources
    resources :function_words, only: %i[index new create]
    resources :topics
    resources :hierarchies do
      delete :remove_image, on: :member
    end
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
    resources :lists do
      delete :remove_word, on: :member
      patch :move_word, on: :member
    end
    post :list_add_word, to: "lists#add_word"
    resources :flashcards, only: :index
    resources :word_view_settings
    resources :keywords, only: %i[index show]

    # User's own routes
    resource :profile, only: %i[show edit update] do
      resources :themes, only: %i[index update], module: :profiles
    end
    resource :avatar, only: :destroy

    scope module: :profiles do
      resource :password, only: :edit
      resource :email, only: :edit
    end

    resource :font, only: :show
    get "ansicht/:word_view_setting_id", to: "homes#show"
  end
end
