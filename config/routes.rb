Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
  resources :employee_listings, only: [:show]

  get "employee/getting_started" => "employee_listings#getting_started"
  get "employee/step_1" => "employee_listings#new_listing_step_1"
  post "employee/step_1" => "employee_listings#create_listing_step_1"
  get "employee/step_2" => "employee_listings#new_listing_step_2"
  post "employee/step_2" => "employee_listings#create_listing_step_2"
  get "employee/step_3" => "employee_listings#new_listing_step_3"
  post "employee/step_3" => "employee_listings#create_listing_step_3"
  get "employee/step_4" => "employee_listings#new_listing_step_4"
  post "employee/step_4" => "employee_listings#create_listing_step_4"
  get "employee/preview" => "employee_listings#preview_listing"
  get "employee/publish" => "employee_listings#publish_listing"
  get "employee/sub_category_lists" => "employee_listings#sub_category_lists"
end
