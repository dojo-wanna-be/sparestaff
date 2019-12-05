class AddStatusFieldToStripeInfo < ActiveRecord::Migration[5.2]
  def change
  	add_column :stripe_infos, :status, :string
  end
end
