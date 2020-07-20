class CreateStripeInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_infos do |t|
      t.references :user, foreign_key: true, index: true
      t.string :stripe_customer_id
      t.string :stripe_account_id
      t.string :last_four_digits
      t.string :card_type

      t.timestamps
    end
  end
end
