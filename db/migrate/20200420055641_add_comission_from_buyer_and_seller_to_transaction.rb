class AddComissionFromBuyerAndSellerToTransaction < ActiveRecord::Migration[5.2]
  def change
  	add_column :transactions, :commission_from_hirer, :float
  	add_column :transactions, :commission_from_poster, :float
  end
end
