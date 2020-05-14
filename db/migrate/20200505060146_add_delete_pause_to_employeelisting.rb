class AddDeletePauseToEmployeelisting < ActiveRecord::Migration[5.2]
  def change
  	add_column :employee_listings, :deleted_at, :boolean, default: false
  	add_column :employee_listings, :pause_at, :boolean, default: false
    add_column :employee_listings, :status, :string
  end
end
