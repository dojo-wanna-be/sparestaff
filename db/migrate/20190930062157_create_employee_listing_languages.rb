class CreateEmployeeListingLanguages < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_listing_languages do |t|
      t.integer :employee_listing_id
      t.integer :language_id

      t.timestamps
    end
  end
end
