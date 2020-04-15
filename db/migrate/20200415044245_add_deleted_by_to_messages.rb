class AddDeletedByToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :deleted_by, :integer, default: nil
  end
end
