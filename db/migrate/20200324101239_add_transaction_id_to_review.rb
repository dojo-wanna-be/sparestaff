class AddTransactionIdToReview < ActiveRecord::Migration[5.2]
  def change
    add_column :reviews, :transaction_id, :integer
    add_column :reviews, :spare_staff_experience, :text
  end
end
