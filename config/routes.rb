Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    omniauth_callbacks: "users/omniauth_callbacks",
    passwords: "users/passwords",
    confirmations: "users/confirmations"
  }

  root to: "home#index"
  namespace :admin do
    resources :users do
      collection do
        get :emails
        post :suspend_or_make_admin_user
        get :suspend_or_delete
      end
    end
    resources :hirings do
      collection do
        get :search
        get :hiring_details
        delete :delete_message
      end
    end
    resources :coupons do
      collection do
        get :user_details
      end
    end
    resources :employee_listings
    resources :community_service_fees
    get '' => "users#index"
  end
  resources :stripe_webhook, only: [] do
    collection do
      post :handle_stripe_webhook
    end
  end

  resources :home, :path => "home", :as => "home", only: [] do
    collection do
      get :email_availability
      get :keyword_search
      get :search
      #get :admin_panel
    end
  end

  resources :reviews do
    collection do
      get :step_2
      get :last_step
    end
  end

  resources :users do
    collection do
      match :profile_photo, via: [:get, :post]
      get :trust_and_verification
      get :show_all_listings
      get :show_all_poster_reviews
      get :show_all_hirer_reviews
      get :destroy_profile_photo
    end
  end

  resources :employee_listings, :path => "employee", :as => "employee", only: [:index, :show, :edit, :update] do
    collection do
      get :user_dashboard
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
    collection do
      get :check_slot_availability
    end
    member do
      match :initialized, via: [:get, :patch]
      get :payment
      patch :request_payment
      get :request_sent_successfully
    end
  end

  resources :hirings, only: [:index, :show] do
    collection do
      get :cancelled_successfully
      patch :send_details
      get :check_slot_availability
    end
    member do
      patch :accept
      patch :decline_request
      patch :decline
      patch :cancel
      get :change_or_cancel
      get :get_receipt
      get :receipt_details
      get :vat_invoice_details
      delete :destroy_transaction
      match :change_hiring, via: [:get, :patch]
      match :change_hiring_confirmation, via: [:get, :patch]
      get :changed_successfully
      match :cancel_hiring, via: [:get, :patch]
      match :tell_poster, via: [:get, :patch]
    end
  end

  resources :reservations, only: [:index, :show] do
    collection do
      get :cancelled_successfully
      get :check_slot_availability
      get :reservations_view_invoice_list
      get :write_a_review
    end
    member do
      patch :accept
      patch :decline_request
      patch :decline
      get :change_or_cancel
      delete :destroy_transaction
      match :change_reservation, via: [:get, :patch]
      match :change_reservation_confirmation, via: [:get, :patch]
      get :changed_successfully
      match :cancel_reservation, via: [:get, :patch]
      match :tell_hirer, via: [:get, :patch]
    end
  end

  resources :payouts, only: [:create, :index] do
    collection do
      get :user_account_notification
      get :step_1
      get :step_2
      get :step_3
      get :step_4
      get :transaction_history
      get :stripe_account
      get :payouts_method
      match :change_preference, via: [:post, :patch]
      match :security, via: [:get, :post]
    end
  end

  resources :inboxes do
    collection do
      get :unread
    end
  end

end
