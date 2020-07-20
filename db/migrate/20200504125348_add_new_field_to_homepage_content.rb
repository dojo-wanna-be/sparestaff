class AddNewFieldToHomepageContent < ActiveRecord::Migration[5.2]
  def change
    add_column :homepage_contents, :getting_start_content_id, :integer
    add_column :frequently_ask_questions, :getting_start_content_id, :integer
  end
end
