class CreateGettingStartContents < ActiveRecord::Migration[5.2]
  def change
    create_table :getting_start_contents do |t|
      t.text :cover_title
      t.text :cover_subtitle
      t.text :button_title
      t.text :list_your_self_title
      t.text :how_it_works_title
      t.text :safety_title
      t.text :frequently_asked_title
      t.text :easy_online_title
      t.attachment :cover_image

      t.timestamps
    end
  end
end
