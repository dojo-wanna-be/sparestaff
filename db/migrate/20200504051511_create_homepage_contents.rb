class CreateHomepageContents < ActiveRecord::Migration[5.2]
  def change
    create_table :homepage_contents do |t|
      t.attachment :content_image
      t.text :content
      t.integer :section_type

      t.timestamps
    end
  end
end
