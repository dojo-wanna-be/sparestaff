class AddNewCardOnStripe

  def initialize(options)
    @user = options[:user]
    @stripe_token = options[:stripe_token]
  end

  def update
    customer = nil
    stripe_info = @user.stripe_info
    begin
      customer = Stripe::Customer.retrieve(stripe_info&.stripe_customer_id)
      customer.source = @stripe_token
      customer.save
      card = customer.sources.data.last
      stripe_info.update_attributes(last_four_digits: card.last4, card_type: card.brand)
    rescue Stripe::InvalidRequestError => e
      # Customer not found, create a new customer
      customer = Stripe::Customer.create(
        email: @user.email,
        source: @stripe_token,
      )
       create_stripe_info(customer)
    end
    return customer
  end

  def create_stripe_info(customer)
    card = customer.sources.data.last
    StripeInfo.create(user_id: @user.id, stripe_customer_id: customer.id, last_four_digits: card.last4, card_type: card.brand)
  end

end