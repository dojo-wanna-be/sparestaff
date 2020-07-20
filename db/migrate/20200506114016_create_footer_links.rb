class CreateFooterLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :footer_links do |t|
      t.integer :link_type
      t.string :link_name
      t.string :link_url
      t.integer :static_content_id

      t.timestamps
    end
  end
end
