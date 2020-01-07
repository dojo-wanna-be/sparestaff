class RemoveFieldFromTransaction < ActiveRecord::Migration[5.2]
  def change
  	remove_column :transactions, :hirer_service_fee, :float
    remove_column :transactions, :hirer_total_service_fee, :float
    remove_column :transactions, :poster_service_fee, :float
    remove_column :transactions, :poster_total_service_fee, :float
  end
end