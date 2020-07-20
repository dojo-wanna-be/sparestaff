class AddColumnsToStaticContent < ActiveRecord::Migration[5.2]
  def change
    add_column :static_contents, :employee_hiring_title, :string
    add_column :static_contents, :how_it_work_title, :string
  end
end
