Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLIC_KEY'],
  secret_key: ENV['STRIPE_SECRET_KEY']
}
Stripe.api_key = ENV['STRIPE_SECRET_KEY']
Stripe.api_version = "2019-05-16"