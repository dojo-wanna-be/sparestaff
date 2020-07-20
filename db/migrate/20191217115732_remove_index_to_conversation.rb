class RemoveIndexToConversation < ActiveRecord::Migration[5.2]
  def change
  	remove_index :conversations, [:receiver_id, :sender_id, :employee_listing_id]
  end
end
