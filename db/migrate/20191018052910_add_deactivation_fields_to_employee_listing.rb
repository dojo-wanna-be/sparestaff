class AddDeactivationFieldsToEmployeeListing < ActiveRecord::Migration[5.2]
  def change
    add_column :employee_listings, :deactivated, :boolean, default: false
    add_column :employee_listings, :deactivation_reason, :integer, default: 7
    add_column :employee_listings, :deactivation_feedback, :text
  end
end
