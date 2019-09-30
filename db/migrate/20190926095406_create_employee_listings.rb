class CreateEmployeeListings < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_listings do |t|
      t.integer :classification_id
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :tfn
      t.integer :birth_year
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :country
      t.integer :post_code
      t.string :residency_status
      t.string :other_residency_status
      t.string :verification_type
      t.string :gender
      t.boolean :has_vehicle, default: false
      t.text :skill_description
      t.text :optional_comments
      t.boolean :published, default: false
      t.integer :lister_id
      t.string :lister_type
      t.integer :listing_step

      t.timestamps
    end
  end
end
