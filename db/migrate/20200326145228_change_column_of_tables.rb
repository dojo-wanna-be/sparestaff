class ChangeColumnOfTables < ActiveRecord::Migration[5.2]
  def change
  	remove_column :users, :role, :string
  	add_column :companies, :role, :string
  end
end
