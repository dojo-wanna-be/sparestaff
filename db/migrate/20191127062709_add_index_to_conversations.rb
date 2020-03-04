class AddIndexToConversations < ActiveRecord::Migration[5.2]
  def change
    remove_index :conversations, [:receiver_id, :sender_id]
    add_index :conversations, [:receiver_id, :sender_id, :employee_listing_id], unique: true, name: 'index_conversations_on_receiver_sender_employee_listing'
  end
end
