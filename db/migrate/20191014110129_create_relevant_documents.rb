class CreateRelevantDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :relevant_documents do |t|
      t.references :employee_listing, foreign_key: true, index: true

      t.timestamps
    end
  end
end
