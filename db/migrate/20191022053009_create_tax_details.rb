class CreateTaxDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :tax_details do |t|
      t.integer :weekly_earning
      t.float :a
      t.float :b

      t.timestamps
    end
  end
end
