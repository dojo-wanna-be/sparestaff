class AddReadToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :read, :boolean, default: false
    remove_column :conversations, :read, :boolean, default: false
  end
end
