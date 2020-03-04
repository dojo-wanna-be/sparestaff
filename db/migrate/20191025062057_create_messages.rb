class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :sender_id
      t.references :conversation, foreign_key: true, index: true

      t.timestamps
    end
  end
end
