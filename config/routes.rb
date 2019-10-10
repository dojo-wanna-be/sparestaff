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

  resources :employee_listings, :path => "employee", :as => "employee", only: [:index, :show] do
    collection do
      get :getting_started, path: "getting_started", as: "getting_started"
      get :sub_category_lists
      get :new_listing_step_1, path: "step_1", as: "step_1"
      post :create_listing_step_1, path: "step_1", as: "create_step_1"
    end
    member do
      get :new_listing_step_2, path: "step_2", as: "step_2"
      post :create_listing_step_2, path: "step_2", as: "create_step_2"
      get :new_listing_step_3, path: "step_3", as: "step_3"
      post :create_listing_step_3, path: "step_3", as: "create_step_3"
      get :new_listing_step_4, path: "step_4", as: "step_4"
      post :create_listing_step_4, path: "step_4", as: "create_step_4"
      get :new_listing_step_5, path: "step_5", as: "step_5"
      post :create_listing_step_5, path: "step_5", as: "create_step_5"
      get :preview_listing, path: "preview", as: "preview"
      get :publish_listing, path: "publish", as: "publish"
    end
  end
end
