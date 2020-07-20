class AddNewFieldsToUser < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :location, :string
    add_column :users, :description, :text
    add_column :users, :role, :string
  end
end
