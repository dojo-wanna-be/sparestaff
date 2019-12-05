class AddNewCardOnStripe

  def initialize(options)
    @user = options[:user]
    @stripe_token = options[:stripe_token]
  end

  def update
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = nil
    stripe_info = @user.stripe_info
    begin
      customer = Stripe::Customer.retrieve(stripe_info.stripe_customer_id)
      customer.source = stripe_token
      customer.save
    rescue Stripe::InvalidRequestError => e
      # Customer not found, create a new customer
      customer = Stripe::Customer.create(
        email: user.email,
        source: stripe_token,
      )
      create_stripe_info(customer.sources.data.last)
    end
    return customer && customer.sources.data.last
  end

  def create_stripe_info(customer)
    StripeInfo.create(user_id: @user.id, stripe_customer_id: customer.id, last_four_digits:  customer.last4, card_type:  customer.brand)
  end

end
