class AddFieldToConversation < ActiveRecord::Migration[5.2]
  def change
  	add_column :conversations, :read, :boolean, default: false
  end
end
