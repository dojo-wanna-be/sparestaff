class CreateEmployeeListingSlots < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_listing_slots do |t|
      t.references :slot, foreign_key: true, index: true
      t.references :employee_listing, foreign_key: true, index: true

      t.timestamps
    end
  end
end
