class CreateEmployeeSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_skills do |t|
      t.string :skill_name
      t.references :employee_listing, foreign_key: true, index: true

      t.timestamps
    end
  end
end
