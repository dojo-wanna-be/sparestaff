class AddServiceFeeFieldsToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :hirer_service_fee, :float
    add_column :transactions, :hirer_total_service_fee, :float
    add_column :transactions, :poster_service_fee, :float
    add_column :transactions, :poster_total_service_fee, :float
  end
end
