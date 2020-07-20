class AddStatusFieldToStripePayment < ActiveRecord::Migration[5.2]
  def change
  	add_column :stripe_payments, :status, :string
  end
end
