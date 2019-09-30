class CreateClassifications < ActiveRecord::Migration[5.2]
  def change
    create_table :classifications do |t|
      t.integer :parent_classification_id
      t.string :name

      t.timestamps
    end
  end
end
