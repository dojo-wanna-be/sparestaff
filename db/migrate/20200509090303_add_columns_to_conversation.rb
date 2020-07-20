class AddColumnsToConversation < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations, :is_disallowed, :boolean, default: false
    add_column :conversations, :deleted_at, :datetime
  end
end
