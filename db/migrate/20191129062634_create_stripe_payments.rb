class CreateStripePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_payments do |t|
    	t.belongs_to :transaction, index: true, foreign_key: true
    	t.string :stripe_charge_id
    	t.float :amount, default: 0
    	t.float :poster_service_fee, default: 0 
    	t.boolean :capture, default: false
      t.timestamps
    end
  end
end
