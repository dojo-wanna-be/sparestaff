class AddStaticContentIdToHomepageContent < ActiveRecord::Migration[5.2]
  def change
    add_column :homepage_contents, :static_content_id, :integer
  end
end
