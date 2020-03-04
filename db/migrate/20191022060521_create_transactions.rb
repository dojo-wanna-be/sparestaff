class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.float :amount
      t.references :employee_listing, foreign_key: true, index: true
      t.boolean :status, default: true
      t.integer :state
      t.boolean :is_withholding_tax, default: true
      t.integer :frequency
      t.integer :hirer_id
      t.integer :poster_id
      t.string :customer_id
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
