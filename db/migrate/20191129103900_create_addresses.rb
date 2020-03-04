class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :country
      t.integer :post_code
      t.belongs_to :transaction, foreign_key: true, index: true

      t.timestamps
    end
  end
end
