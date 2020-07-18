class AddTitleToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :title, :string
  end
end
