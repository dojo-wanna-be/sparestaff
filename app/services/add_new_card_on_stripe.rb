class AddNewCardOnStripe
  attr_reader :user, :new_card

  def initialize(options)
    @user = options[:user]
    @new_card = options[:new_card]
  end

  def update
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    customer = nil
    begin
      customer = Stripe::Customer.retrieve(user.stripe_customer_id)
      customer.source = new_card
      customer.save
    rescue Stripe::InvalidRequestError => e
      # Customer not found, create a new customer
      customer = Stripe::Customer.create(
        email: user.email,
        source: new_card,
      )
      user.update(stripe_customer_id: customer.id)
    end
    
    return customer && customer.sources.data.last 
  end
end