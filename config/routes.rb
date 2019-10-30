Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }

  root to: "home#index"

  resources :home, :path => "home", :as => "home", only: [] do
    collection do
      get :email_availability
    end
  end

  resources :employee_listings, :path => "employee", :as => "employee", only: [:index, :show, :edit, :update] do
    collection do
      get :user_dashboard
      get :inbox, path: "message_inbox", as: "message_inbox"
      get :getting_started, path: "getting_started", as: "getting_started"
      get :deactivated_completely, path: "deactivated", as: "deactivated"
      get :sub_category_lists
      get :new_listing_step_1, path: "step_1", as: "step_1"
      patch :create_listing_step_1, path: "step_1", as: "create_step_1"
      patch :add_relevant_document, path: "relevant_document", as: "relevant_document"
      patch :add_profile_picture, path: "profile_picture", as: "profile_picture"
      patch :add_verification_front, path: "verification_front", as: "verification_front"
      patch :add_verification_back, path: "verification_back", as: "verification_back"
    end
    member do
      get :new_listing_step_2, path: "step_2", as: "step_2"
      patch :create_listing_step_2, path: "step_2", as: "create_step_2"
      get :new_listing_step_3, path: "step_3", as: "step_3"
      patch :create_listing_step_3, path: "step_3", as: "create_step_3"
      get :new_listing_step_4, path: "step_4", as: "step_4"
      patch :create_listing_step_4, path: "step_4", as: "create_step_4"
      get :new_listing_step_5, path: "step_5", as: "step_5"
      patch :create_listing_step_5, path: "step_5", as: "create_step_5"
      get :preview_listing, path: "preview", as: "preview"
      match :publish_listing, path: "publish", as: "publish", via: [:get, :patch]
      patch :listing_deactivation, path: "deactivate_listing", as: "deactivate"
    end
  end

  resources :transactions, only: [:create] do
    member do
      match :initialized, via: [:get, :patch]
      match :payment, via: [:get, :patch]
    end
  end
end
