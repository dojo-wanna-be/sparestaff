class AddNewFieldToHomepageContentNew < ActiveRecord::Migration[5.2]
  def change
    add_column :homepage_contents, :content_heading, :text
  end
end
