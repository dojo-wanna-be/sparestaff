class AddNewCardOnStripe
  attr_reader :user, :stripe_token

  def initialize(options)
    @user = options[:user]
    @stripe_token = options[:stripe_token]
  end

  def update
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = nil
    stripe_info = user.stripe_info
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
      stripe_info.update(stripe_customer_id: customer.id)
    end
    
    return customer && customer.sources.data.last 
  end
end
