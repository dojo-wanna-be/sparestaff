class CreateEmployeeHireSections < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_hire_sections do |t|
      t.text :column_1_text
      t.text :column_2_text
      t.text :column_3_text
      t.text :column_4_text
      t.attachment :column_1_image
      t.attachment :column_2_image
      t.attachment :column_3_image
      t.attachment :column_4_image

      t.timestamps
    end
  end
end
